function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isBlank)

% config.LogTransformedCorrection
% config.RemoveZeros
% config.OutlierDetectionMethod
% config.OutlierDetectionCI
% config.OutlierReplacementStrategy
% config.WithinBatchCorrectionMode
% config.BetweenBatchCorrectionMode
% config.QCRSCgammaConstraint
% config.QCRSCcvMethod
% config.QCRSCmcReps
% config.BlankRatioMethod
% config.RelativeLOQ
% config.ParallelProcess

switch config.QCRSCcvMethod
    case '3-Fold', QCRSCcvMethod = 3;
    case '5-Fold', QCRSCcvMethod = 5;
    case '7-Fold', QCRSCcvMethod = 7;
    case 'Leaveout', QCRSCcvMethod = -1;
    otherwise, error('This CrossValidation method does not exist'); 
end

switch config.OutlierDetectionMethod
    case 'None', OutlierMethod = 'none';
    case 'Percentile', OutlierMethod = 'prctile';
    case 'Linear', OutlierMethod = 'poly1';                    
    case 'Quadratic', OutlierMethod = 'poly2';                    
    case 'Cubic', OutlierMethod = 'poly3';                    
    otherwise, error('This OutlierDetectionMethod does not exist');                    
end

if strcmp(config.WithinBatchCorrectionMode,'Sample')
    mpv = median(y(isSample),'omitnan');
else
    mpv = median(y(isQC),'omitnan');
end

if config.LogTransformedCorrection
    CorrectionType = 'Subtract';
else
    CorrectionType = 'Divide';
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

gammaRange = config.QCRSCgammaConstraint:15;

for i = 1:numberOfBatches
      
    idx = batchqc == ub(i);
    tqci = tqc(idx);
    yqci = yqc(idx);

    try        
        [tqci,yqci,toutlieri] = OutlierFilter(tqci,yqci,OutlierMethod,config.OutlierDetectionCI);
        switch config.WithinBatchCorrectionMode
            case 'Sample'
                gamma = 10000;epsilon = NaN;cvMse = 0;minVal = 0;
            case 'Median'
                gamma = NaN;epsilon = NaN;cvMse = 0;minVal = 0;
            case 'Linear'
                %avDist = median(tqci(2:end) - tqci(1:end-1));
                %epsilon = avDist^3/16;
                %gamma = 11;cvMse = 0;minVal = 0;
                gamma = 1000;epsilon = NaN;cvMse = 0;minVal = 0;
            otherwise
                [gamma,epsilon,cvMse,minVal] = optimiseCSAPS(tqci,yqci,gammaRange,QCRSCcvMethod,config.QCRSCmcReps);               
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
        [z(idx),yspline(idx)] = QCRSC3(ti,yi,isQCi,isSamplei,mpv,epsilonVal(i),gammaVal(i),toutliers,CorrectionType,config.OutlierReplacementStrategy);
    catch
        z(idx) = yi;
    end
    %next line stops the blank from being corrected - disabled
    %z(isBlank) = y(isBlank);   
end



end

