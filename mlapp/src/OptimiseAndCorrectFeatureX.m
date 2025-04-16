function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeatureX(config,t,y,batch,isQC,isSample,isRef,isBlank)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isRef,isBlank);
    if strcmp(config.BetweenBatchCorrectionMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierDetectionMethod = 'None';
         tempConfig.WithinBatchCorrectionMode = 'Median';
        z = OptimiseAndCorrectFeature(tempConfig,t,z,batch,isRef,isSample,isRef,isBlank);
    end
    if strcmp(config.BetweenBatchCorrectionMode,'Sample')
        tempConfig = config;
        tempConfig.OutlierDetectionMethod = 'None';
         tempConfig.WithinBatchCorrectionMode = 'Median';
        z = OptimiseAndCorrectFeature(tempConfig,t,z,batch,isSample,isSample,isRef,isBlank);
    end

end