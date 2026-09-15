function [z,yspline,gammaVal,toutliers,mpv] = OptimiseAndCorrectFeatureXManual(config,t,y,batch,isQC,isSample,isBlank,isRef,isOutlier,OptStruct)
    [z,yspline,gammaVal,toutliers,mpv] = OptimiseAndCorrectFeatureManual(config,t,y,batch,isQC,isSample,isBlank,isOutlier,OptStruct);
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