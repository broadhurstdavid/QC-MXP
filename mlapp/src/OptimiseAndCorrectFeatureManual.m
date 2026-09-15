function [z,yspline,gammaVal,toutliers,mpv] = OptimiseAndCorrectFeatureManual(config,t,y,batch,isQC,isSample,isBlank,isOutlier,OptStruct)

switch config.OutlierDetectionMethod
    case 'None', OutlierMethod = 'none';
    case 'Percentile', OutlierMethod = 'prctile';
    case 'Linear', OutlierMethod = 'poly1';                    
    case 'Quadratic', OutlierMethod = 'poly2';                    
    case 'Cubic', OutlierMethod = 'poly3';
    case 'Manual', OutlierMethod = 'manual';
    otherwise, error('This OutlierDetectionMethod does not exist');                    
end


switch config.WithinBatchCorrectionMode
    case 'Sample'
        mpv = median(y(isSample),'omitnan');
    otherwise
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



toutliers = [];

yqc = y(isQC);
missing = isnan(yqc);
isQC(missing) = false;
yqc = y(isQC);
tqc = t(isQC);
batchqc = batch(isQC);
if strcmp(OutlierMethod,'manual')
    isOutlierqc = isOutlier(isQC);
end

for i = 1:numberOfBatches
      
    idx = batchqc == ub(i);
    tqci = tqc(idx);
    yqci = yqc(idx);

    try 
        if strcmp(OutlierMethod,'manual')
            oqci = isOutlierqc(idx);
            toutlieri = tqci(oqci);
            tqci = tqci(~oqci);
            yqci = yqci(~oqci);
        else
            [~,~,toutlieri] = OutlierFilter(tqci,yqci,OutlierMethod,config.OutlierDetectionCI);
        end     
    catch
        toutlieri = [];
    end            
    toutliers = [toutliers;toutlieri];
end

gammaVal = nan(numberOfBatches,1);

for i = 1:numberOfBatches
    idx = batch==ub(i);
    ti = t(idx);
    yi = y(idx);
    isQCi = isQC(idx);
    isSamplei = isSample(idx);
    gammaVal(i) = OptStruct(i).gamma;
    try
        [z(idx),yspline(idx)] = QCRSC3(ti,yi,isQCi,isSamplei,mpv,OptStruct(i).epsilon,OptStruct(i).gamma,toutliers,CorrectionType,config.OutlierReplacementStrategy);
    catch
        z(idx) = yi;
    end
    %next line stops the blank from being corrected - disabled
    z(isBlank) = y(isBlank);   
end


end

