function baseConfig = validateConfig(baseConfig)

defaultFieldnames = [
    {'LogTransform'     }
    {'RemoveZeros'      }
    {'OutlierScope'     }
    {'OutlierMethod'    }
    {'OutlierCI'        }
    {'OutlierPostHoc'   }
    {'IntraBatchMode'   }
    {'InterBatchMode'   }
    {'QCRSCgammaRange'  }
    {'QCRSCcvMethod'    }
    {'QCRSCmcReps'      }
    {'CorrectionType'   }
    {'BlankRatioMethod' }
    {'RelativeLOD'      }
    {'StatsParametric'  }
    {'ParallelProcess'  }];

baseFieldnames = fieldnames(baseConfig);

if ~isequal(defaultFieldnames,baseFieldnames)
    ME = MException('QCRSC:MismatchConfigStruct','Config Error: Incomplete configuration list');
    throw(ME);
end

try
    validateattributes(baseConfig.LogTransform, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedLogTransform','Config Error: LogTransform value must be logical (true/false)');
    throw(baseException)
end

try
    validateattributes(baseConfig.RemoveZeros, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedRemoveZeros','Config Error: RemoveZeros value must be logical (true/false)');
    throw(baseException)
end

try
    mustBeMember(baseConfig.OutlierScope,{'Local','Global','Global&Local'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierScope',"Config Error: OutlierScope value must be one of the following: 'Local','Global','Global&Local'");
    throw(baseException)
end

try
    mustBeMember(baseConfig.OutlierMethod,{'None','Percentile','Linear','Quadratic','Cubic'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierMethod',"Config Error: OutlierMethod value must be one of the following: 'None', 'Percentile', 'Linear', 'Quadratic', 'Cubic'");
    throw(baseException)
end

try
    mustBeInRange(baseConfig.OutlierCI,0.9,1);
catch
    baseException = MException('QCRSC:UnexpectedOutlierCI',"OutlierCI value must lie be between 0.9 and 1");
    throw(baseException)
end
    
try
    mustBeMember(baseConfig.OutlierPostHoc,{'Ignore','MPV','NaN'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierPostHoc',"OutlierPostHoc value must be one of the following: 'Ignore', 'MPV', 'NaN'");
    throw(baseException)
end   

if isa(baseConfig.QCRSCgammaRange,'char')   
    baseConfig.QCRSCgammaRange = str2num(baseConfig.QCRSCgammaRange);
    if isempty(baseConfig.QCRSCgammaRange)    
        baseException = MException('QCRSC:UnexpectedQCRSCgammaRange',"QCRSCgammaRange must be formatted as 'lower:increment:upper' (e.g. '-1:0.5:4')");
        throw(baseException)
    end
end

try
    mustBeMember(baseConfig.IntraBatchMode,{'Median','Linear','Spline'});
catch
    baseException = MException('QCRSC:UnexpectedIntraBatchMode',"IntraBatchMode value must be one of the following: 'Median','Linear','Spline'");
    throw(baseException)
end  

try
    mustBeMember(baseConfig.InterBatchMode,{'QC','Reference'});
catch
    baseException = MException('QCRSC:UnexpectedInterBatchMode',"InterBatchMode value must be one of the following: 'QC','Reference'");
    throw(baseException)
end  

try
    validateattributes(baseConfig.QCRSCgammaRange, {'double'},{'nonempty','increasing','<=',10})
catch
    baseException = MException('QCRSC:UnexpectedQCRSCgammaRange',"QCRSCgammaRange value must be a numerical vector of increasing value. Maximum = 10");
    throw(baseException)
end 

try
    mustBeMember(baseConfig.QCRSCcvMethod,{'3-Fold','5-Fold','7-Fold','Leaveout'});
catch
    baseException = MException('QCRSC:UnexpectedQCRSCcvMethod',"QCRSCcvMethod value must be one of the following: '3-Fold','5-Fold','7-fold','Leaveout'");
    throw(baseException)
end  

try
    validateattributes(baseConfig.QCRSCmcReps, {'double'},{'scalar','integer','nonnegative'})
catch
    baseException = MException('QCRSC:UnexpectedQCRSCmcReps',"QCRSCmcReps value must be a nonnegtive integer");
    throw(baseException)
end 

try
    mustBeMember(baseConfig.CorrectionType,{'Subtract','Divide'});
catch
    baseException = MException('QCRSC:UnexpectedCorrectionType',"CorrectionType value must be either 'Subtract' or 'Divide'");
    throw(baseException)
end 

try
    mustBeMember(baseConfig.BlankRatioMethod,{'QC','Median','Percentile'});
catch
    baseException = MException('QCRSC:UnexpectedBlankRatioMethod',"BlankRatioMethod value must be one of the following: 'QC','Median','Percentile'");
    throw(baseException)
end 

try
    validateattributes(baseConfig.RelativeLOD, {'double'},{'scalar','nonnegative'})
catch
    baseException = MException('QCRSC:UnexpectedRelativeLOD',"RelativeLOD value must be a nonnegtive number");
    throw(baseException)
end 

try
    validateattributes(baseConfig.StatsParametric, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedStatsParametric',"StatsParametric value must must be logical (true/false)");
    throw(baseException)
end 

try
    validateattributes(baseConfig.ParallelProcess, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedParallelProcess',"ParallelProcess value must must be logical (true/false)");
    throw(baseException)
end 

switch baseConfig.QCRSCcvMethod
    case '3-Fold', baseConfig.QCRSCcvMethod = 3;
    case '5-Fold', baseConfig.QCRSCcvMethod = 5;
    case '7-Fold', baseConfig.QCRSCcvMethod = 7;
    case 'Leaveout', baseConfig.QCRSCcvMethod = -1;
    otherwise, error('This CrossValidation method does not exist'); 
end

switch baseConfig.OutlierMethod
    case 'None', baseConfig.OutlierMethod = 'none';
    case 'Percentile', baseConfig.OutlierMethod = 'prctile';
    case 'Linear', baseConfig.OutlierMethod = 'poly1';                    
    case 'Quadratic', baseConfig.OutlierMethod = 'poly2';                    
    case 'Cubic', baseConfig.OutlierMethod = 'poly3';                    
    otherwise, error('This OutlierMethod does not exist');                    
end

end

