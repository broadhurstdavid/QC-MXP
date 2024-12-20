function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isBlank)

% config.LogTransform
% config.RemoveZeros
% config.OutlierMethod
% config.OutlierCI
% config.OutlierPostHoc
% config.IntraBatchMode
% config.InterBatchMode
% config.QCRSCgammaRange
% config.QCRSCcvMethod
% config.QCRSCmcReps
% config.CorrectionType
% config.BlankRatioMethod
% config.RelativeLOD
% config.StatsParametric
% config.ParallelProcess

if strcmp(config.IntraBatchMode,'Sample')
    mpv = median(y(isSample),'omitnan');
else
    mpv = mean(y(isQC),'omitnan');
end

z = nan(length(y),1);
yspline = nan(length(y),1);
ub = unique(batch);
numberOfBatches = length(ub);

gammaVal = nan(numberOfBatches,1);
epsilonVal = nan(numberOfBatches,1);

Report(numberOfBatches).gamma = NaN;
Report(numberOfBatches).cvMse = NaN;
Report(numberOfBatches).minVal = NaN;
Report(numberOfBatches).outliers = NaN;

toutliers = [];

yqc = y(isQC);
missing = isnan(yqc);
isQC(missing) = false;
yqc = y(isQC);
tqc = t(isQC);
batchqc = batch(isQC);

for i = 1:numberOfBatches
      
    idx = batchqc == ub(i);
    tqci = tqc(idx);
    yqci = yqc(idx);

    try        
        [tqci,yqci,toutlieri] = OutlierFilter(tqci,yqci,config.OutlierMethod,config.OutlierCI);
        switch config.IntraBatchMode
            case 'Sample'
                gamma = 10000;epsilon = NaN;cvMse = 0;minVal = 0;
            case 'Mean'
                gamma = NaN;epsilon = NaN;cvMse = 0;minVal = 0;
            case 'Linear'
                %avDist = median(tqci(2:end) - tqci(1:end-1));
                %epsilon = avDist^3/16;
                %gamma = 11;cvMse = 0;minVal = 0;
                gamma = 1000;epsilon = NaN;cvMse = 0;minVal = 0;
            otherwise
                [gamma,epsilon,cvMse,minVal] = optimiseCSAPS(tqci,yqci,config.QCRSCgammaRange,config.QCRSCcvMethod,config.QCRSCmcReps);               
        end
   catch
       gamma = NaN;epsilon = NaN;cvMse = NaN;minVal = NaN;toutlieri = [];
   end             
    
    gammaVal(i) = gamma;
    epsilonVal(i) = epsilon;
    Report(i).gamma = gamma;
    Report(i).cvMse = cvMse;
    Report(i).minVal = minVal;
    toutliers = [toutliers;toutlieri];
end

for i = 1:numberOfBatches
    idx = batch==ub(i);
    ti = t(idx);
    yi = y(idx);
    isQCi = isQC(idx);
    isSamplei = isSample(idx);
    try
        [z(idx),yspline(idx)] = QCRSC3(ti,yi,isQCi,isSamplei,mpv,epsilonVal(i),gammaVal(i),toutliers,config.CorrectionType,config.OutlierPostHoc);
    catch
        z(idx) = yi;
    end
    %next line stops the blank from being corrected - disabled
    %z(isBlank) = y(isBlank);   
end



end

