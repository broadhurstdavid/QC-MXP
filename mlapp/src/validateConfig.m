function baseConfig = validateConfig(baseConfig)



defaultFieldnames = [
  {'Filename'}
  {'DataSheet'}
  {'FeatureDictionary'}
  {'PreFilterPercentQCsMissingPerFeature'}
  {'PreFilterMode'}
  {'LOQfilter'}
  {'RelativeLOQ'}
  {'LogTransformedCorrection'}
  {'RemoveZeros'}
  {'OutlierDetectionMethod'}
  {'OutlierDetectionCI'}
  {'OutlierReplacementStrategy'}
  {'WithinBatchCorrectionMode'}
  {'BetweenBatchCorrectionMode'}
  {'QCRSCgammaRange'}
  {'QCRSCcvMethod'}
  {'QCRSCmcReps'}
  {'BlankRatioMethod'}
  {'ParallelProcess'}
  {'CleaningMissingDataMode'}
  {'CleaningPercentMissingPerFeature'}
  {'CleaningFilterMode'}
  {'CleaningFilterQCRSD'}
  {'CleaningFilterSampleRSD'}
  {'CleaningFilterDRatio'}
  {'CleaningFilterBlankRatio'}
  {'CleanedLogTransform'}
  {'CleanedScaleMethod'}
  {'CleanedImputationMethod'}
  {'CleanedImputationK'}];

baseFieldnames = fieldnames(baseConfig);

if ~isequal(defaultFieldnames,baseFieldnames)
    ME = MException('QCRSC:MismatchConfigStruct','Config Error: Incomplete configuration list');
    throw(ME);
end

try
    validateattributes(baseConfig.Filename,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedFilename','Config Error: Filename value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.DataSheet,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedDataSheet','Config Error: DataSheet value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.FeatureDictionary,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedFeatureDictionary','Config Error: FeatureDictionary value must be text');
    throw(baseException)
end

try
    validateattributes(baseConfig.PreFilterPercentQCsMissingPerFeature, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedPreFilterPercentQCsMissingPerFeatureValue','Config Error: PreFilter % QC Missing Per Feature value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.PreFilterMode,{'Complete','Every Batch','Any Batch'});
catch
    baseException = MException('QCRSC:UnexpectedPreFilterMode',"Config Error: PreFilter Mode must be one of the following: 'Complete','Every Batch','Any Batch'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.LOQfilter, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedLOQfilterValue','Config Error: LOQfilter value must be logical (true/false)');
    throw(baseException)
end

try
    validateattributes(baseConfig.RelativeLOQ, {'double'},{'scalar','nonnegative'})
catch
    baseException = MException('QCRSC:UnexpectedRelativeLOQ',"RelativeLOQ value must be a nonnegtive number");
    throw(baseException)
end 

try
    validateattributes(baseConfig.LogTransformedCorrection, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedLogTransformedCorrectionValue','Config Error: LogTransformedCorrection value must be logical (true/false)');
    throw(baseException)
end

try
    validateattributes(baseConfig.RemoveZeros, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedRemoveZerosValue','Config Error: RemoveZeros value must be logical (true/false)');
    throw(baseException)
end


try
    mustBeMember(baseConfig.OutlierDetectionMethod,{'None','Percentile','Linear','Quadratic','Cubic'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierDetectionMethod',"Config Error: Outlier Detection Method must be one of the following: 'None', 'Percentile', 'Linear', 'Quadratic', 'Cubic'");
    throw(baseException)
end

try
    mustBeInRange(baseConfig.OutlierDetectionCI,0.9,0.999);
catch
    baseException = MException('QCRSC:UnexpectedOutlierDetectionCI',"Outlier Detection CI value must lie be between 0.9 and 0.999");
    throw(baseException)
end
    
try
    mustBeMember(baseConfig.OutlierReplacementStrategy,{'Ignore','Median','NaN'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierReplacementStrategy',"QC Outlier Replacement Strategy must be one of the following: 'Ignore', 'Median', 'NaN'");
    throw(baseException)
end

try
    mustBeMember(baseConfig.WithinBatchCorrectionMode,{'Sample','Median','Linear','Spline'});
catch
    baseException = MException('QCRSC:UnexpectedWithinBatchCorrectionMode',"WithinBatchCorrectionMode value must be one of the following: 'Sample','Median','Linear','Spline'");
    throw(baseException)
end  

try
    mustBeMember(baseConfig.BetweenBatchCorrectionMode,{'QC','Reference','Sample'});
catch
    baseException = MException('QCRSC:UnexpectedBetweenBatchCorrectionMode',"BetweenBatchCorrectionMode value must be one of the following: 'Sample','QC','Reference'");
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
    mustBeMember(baseConfig.BlankRatioMethod,{'QC','Median','Percentile'});
catch
    baseException = MException('QCRSC:UnexpectedBlankRatioMethod',"BlankRatioMethod value must be one of the following: 'QC','Median','Percentile'");
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

switch baseConfig.OutlierDetectionMethod
    case 'None', baseConfig.OutlierDetectionMethod = 'none';
    case 'Percentile', baseConfig.OutlierDetectionMethod = 'prctile';
    case 'Linear', baseConfig.OutlierDetectionMethod = 'poly1';                    
    case 'Quadratic', baseConfig.OutlierDetectionMethod = 'poly2';                    
    case 'Cubic', baseConfig.OutlierDetectionMethod = 'poly3';                    
    otherwise, error('This OutlierDetectionMethod does not exist');                    
end

if baseConfig.LogTransform
    baseConfig.CorrectionType = 'Subtract';
else
    baseConfig.CorrectionType = 'Divide';
end

try
    mustBeMember(baseConfig.CleaningMissingDataMode,{'Complete','Every Batch','Any Batch'});
catch
    baseException = MException('QCRSC:UnexpectedCleaningMissingDataMode',"Config Error: Cleaning Missing Data Mode must be one of the following: 'Complete','Every Batch','Any Batch'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningPercentMissingPerFeature, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningPercentMissingPerFeature','Config Error: Cleaning % Missing per Feature value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleaningFilterMode,{'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'});
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterMode',"Config Error: Cleaning Missing Filter Mode must be one of the following: 'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterQCRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterQCRSD','Config Error: Cleaning Filter QCRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterSampleRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterSampleRSD','Config Error: Cleaning Filter SampleRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterDRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterDRatio','Config Error: Cleaning Filter D-Ratio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterBlankRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterBlankRatio','Config Error: Cleaning Filter Blank-Ratio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanedLogTransform, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedCleanedLogTransformValue','Config Error: Cleaned Log Transform value must be logical (true/false)');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanedScaleMethod,{'None','Autoscale','Paretoscale'});
catch
    baseException = MException('QCRSC:UnexpectedCleanedScaleMethod',"Config Error: Cleaned Scale Method must be one of the following: 'None','Autoscale','Paretoscale'.");
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanedImputeMethod,{'KNNcolumn','KNNrow','blank20'});
catch
    baseException = MException('QCRSC:UnexpectedCleanedImputeMethod',"Config Error: Cleaned Impute Method must be one of the following: 'KNNcolumn','KNNrow','blank20'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanedImputationK, {'double'},{'scalar','integer','>=',1,'<=',20})
catch
    baseException = MException('QCRSC:UnexpectedCleanedImputationKvalue','Config Error: Cleaned imputation K value must be a positive integer between 1 and 20');
    throw(baseException)
end



end

