function [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectPeakX(config,t,y,batch,isQC,isREF)
    [z,yspline,gammaVal,toutliers,Report] = OptimiseAndCorrectPeak(config,t,y,batch,isQC);
    if strcmp(config.InterBatchMode,'Reference')
        tempConfig = config;
        tempConfig.OutlierMethod = 'none';
        tempConfig.OutlierScope = 'Local';
         tempConfig.IntraBatchMode = 'Mean';
        z = OptimiseAndCorrectPeak(tempConfig,t,z,batch,isREF);
    end
end