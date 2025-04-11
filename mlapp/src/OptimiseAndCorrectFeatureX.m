function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeatureX(config,t,y,batch,isQC,isSample,isREF,isBlank)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isBlank);
    if strcmp(config.BetweenBatchCorrectionMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierDetectionMethod = 'none';
         tempConfig.WithinBatchCorrectionMode = 'Median';
        z = OptimiseAndCorrectFeature(tempConfig,t,z,batch,isREF,isSample,isBlank);
    end
end