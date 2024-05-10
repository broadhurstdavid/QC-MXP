function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectPeak(config,t,y,batch,isQC,isBlank)

% config.LogTransform
% config.RemoveZeros
% config.OutlierScope
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


mpv = mean(y(isQC),'omitnan');

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

if ismember(config.OutlierScope,{'Global','Global&Local'})
    %[~,~,toutliers] = OutlierFilter(tqc,yqc,config.OutlierMethod,0.99,lowonly=true);
    [~,~,toutliers] = OutlierFilter(tqc,yqc,config.OutlierMethod,config.OutlierCI);
    found = ismember(tqc,toutliers);
    tqc(found) = [];
    yqc(found) = [];
    batchqc(found) = [];
end



for i = 1:numberOfBatches
      
    idx = batchqc == ub(i);
    tqci = tqc(idx);
    yqci = yqc(idx);


%     idx = batch==ub(i);
%     ti = t(idx);
%     yi = y(idx);
%     qci = isQC(idx);
%     
%     missing = isnan(yi);
%     qci(missing) = false;
%     
%     tqci = ti(qci);
%     yqci = yi(qci);
    try
        if ismember(config.OutlierScope,{'Local','Global&Local'})
            [tqci,yqci,toutlieri] = OutlierFilter(tqci,yqci,config.OutlierMethod,config.OutlierCI);
        else
            toutlieri = [];
        end
        switch config.IntraBatchMode
            case 'Mean'
                gamma = NaN;epsilon = NaN;cvMse = 0;minVal = 0;
            case 'Linear'
                avDist = median(tqci(2:end) - tqci(1:end-1));
                epsilon = avDist^3/16;
                gamma = 11;cvMse = 0;minVal = 0;
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
    qci = isQC(idx);
    missing = isnan(yi);
    qci(missing) = false;
    try
        [z(idx),yspline(idx)] = QCRSC(ti,yi,qci,mpv,epsilonVal(i),gammaVal(i),toutliers,config.CorrectionType,config.OutlierPostHoc);
    catch
        z(idx) = yi;
    end
    %next line stops the blank from being corrected - disabled
    %z(isBlank) = y(isBlank);   
end



end

