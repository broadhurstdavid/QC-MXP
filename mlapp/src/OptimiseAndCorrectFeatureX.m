function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeatureX(config,t,y,batch,isQC,isSample,isREF,isBlank)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isBlank);
    if strcmp(config.BetweenBatchMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierDetectionMethod = 'none';
         tempConfig.BetweenBatchMode = 'Mean';
        z = OptimiseAndCorrectFeature(tempConfig,t,z,batch,isREF,isSample,isBlank);
    end
end