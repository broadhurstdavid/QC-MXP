function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectPeakX(config,t,y,batch,isQC,isREF,isBlank)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectPeak(config,t,y,batch,isQC,isBlank);
    if strcmp(config.InterBatchMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierMethod = 'none';
         tempConfig.IntraBatchMode = 'Mean';
        z = OptimiseAndCorrectPeak(tempConfig,t,z,batch,isREF,isBlank);
    end
end