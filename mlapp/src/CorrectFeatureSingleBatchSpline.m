function [z,yspline] = CorrectFeatureSingleBatchSpline(config,t,y,z0,yspline0,batch,isQC,isSample,isBlank,isOutlier,batchNumber,gammaVal,epsilonVal)

mpv = median(y(isQC),'omitnan');


if config.LogTransformedCorrection
    CorrectionType = 'Subtract';
else
    CorrectionType = 'Divide';
end

yqc = y(isQC);
missing = isnan(yqc);
isQC(missing) = false;

z = z0;
yspline = yspline0;


idx = batch == batchNumber;
ti = t(idx);
yi = y(idx);
isQCi = isQC(idx);
isSamplei = isSample(idx);

isOutlieri = isOutlier(idx);
toutlieri = ti(isOutlieri);


try
    [z(idx),yspline(idx)] = QCRSC3(ti,yi,isQCi,isSamplei,mpv,epsilonVal,gammaVal,toutlieri,CorrectionType,config.OutlierReplacementStrategy);
catch
    z = z0;
end
z(isBlank) = y(isBlank);   

end