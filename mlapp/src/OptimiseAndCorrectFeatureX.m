function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeatureX(config,t,y,batch,isQC,isSample,isREF,isBlank)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectFeature(config,t,y,batch,isQC,isSample,isBlank);
    if strcmp(config.InterBatchMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierMethod = 'none';
         tempConfig.IntraBatchMode = 'Mean';
        z = OptimiseAndCorrectFeature(tempConfig,t,z,batch,isREF,isBlank);
    end
end