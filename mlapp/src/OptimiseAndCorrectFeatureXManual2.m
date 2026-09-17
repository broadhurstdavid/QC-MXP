function [z,yspline] = OptimiseAndCorrectFeatureXManual2(config,t,y,batch,isQC,isSample,isBlank,isRef,isOutlier,gammaVal,epsilonVal)
    [z,yspline] = OptimiseAndCorrectFeatureManual2(config,t,y,batch,isQC,isSample,isBlank,isOutlier,gammaVal,epsilonVal);
    if strcmp(config.BetweenBatchCorrectionMode,'Reference')
        tempConfig = config;
        if ~strcmp(tempConfig.OutlierDetectionMethod,'Manual')
            tempConfig.OutlierDetectionMethod = 'None';
        end
         tempConfig.WithinBatchCorrectionMode = 'Median';
        z = OptimiseAndCorrectFeatureManual(tempConfig,t,z,batch,isRef,isSample,isBlank,isOutlier,OptStruct);
    end
    if strcmp(config.BetweenBatchCorrectionMode,'Sample')
        tempConfig = config;
        tempConfig.OutlierDetectionMethod = 'None';
        tempConfig.WithinBatchCorrectionMode = 'Median';
        z = OptimiseAndCorrectFeatureManual(tempConfig,t,z,batch,isSample,isSample,isBlank,isOutlier,OptStruct);
    end

end