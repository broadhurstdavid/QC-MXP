function baseConfig = validateConfig(baseConfig)

defaultFieldnames = [
  {'Filename'}
  {'DataTable'}
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
  {'CorrectedFileSuffix'}
  {'CleaningFilterMode'}
  {'CleaningPercentMissingPerFeature'}
  {'CleaningFilterMode2'}
  {'CleaningFilterQCRSD'}
  {'CleaningFilterSampleRSD'}
  {'CleaningFilterDRatio'}
  {'CleaningFilterBlankRatio'}
  {'CleanedFileSuffix'}
  {'CleanedLogTransform'}
  {'CleanedScaleMethod'}
  {'CleanedImputationMethod'}
  {'CleanedImputationK'}];

baseFieldnames = fieldnames(baseConfig);

if ~isequal(defaultFieldnames,baseFieldnames)
    ME = MException('QCRSC:MismatchConfigStruct','Config Error: Incomplete or mislabled configuration structure');
    throw(ME);
end

try
    validateattributes(baseConfig.Filename,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedFilename','Config Error: Filename value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.DataTable,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedDataTable','Config Error: DataTable value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.FeatureDictionary,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedFeatureDictionary','Config Error: FeatureDictionary value must be text');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanedFileSuffix,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedCleanedFileSuffix','Config Error: CleanedFileSuffix value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.CorrectedFileSuffix,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedCorrectedFileSuffix','Config Error: CorrectedFileSuffix value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.PreFilterPercentQCsMissingPerFeature, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedPreFilterPercentQCsMissingPerFeatureValue','Config Error: PreFilterPercentQCsMissingPerFeatureValue value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.PreFilterMode,{'Complete','EveryBatch','AnyBatch'});
catch
    baseException = MException('QCRSC:UnexpectedPreFilterMode',"Config Error: PreFilterMode must be one of the following: 'Complete','Every Batch','Any Batch'.");
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
    baseException = MException('QCRSC:UnexpectedOutlierDetectionMethod',"Config Error: OutlierDetectionMethod must be one of the following: 'None', 'Percentile', 'Linear', 'Quadratic', 'Cubic'");
    throw(baseException)
end

try
    mustBeInRange(baseConfig.OutlierDetectionCI,0.9,0.999);
catch
    baseException = MException('QCRSC:UnexpectedOutlierDetectionCI',"OutlierDetectionCI value must lie be between 0.9 and 0.999");
    throw(baseException)
end
    
try
    mustBeMember(baseConfig.OutlierReplacementStrategy,{'Ignore','Median','NaN'});
catch
    baseException = MException('QCRSC:UnexpectedOutlierReplacementStrategy',"QCOutlierReplacementStrategy must be one of the following: 'Ignore', 'Median', 'NaN'");
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
    QCRSCgammaRange = str2num(baseConfig.QCRSCgammaRange);
    if isempty(QCRSCgammaRange)    
        baseException = MException('QCRSC:UnexpectedQCRSCgammaRange',"QCRSCgammaRange must be formatted as 'lower:increment:upper' (e.g. '-1:0.5:4')");
        throw(baseException)
    end
end

try
    validateattributes(QCRSCgammaRange, {'double'},{'nonempty','increasing','<=',10})
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

try
    mustBeMember(baseConfig.CleaningFilterMode,{'Complete','EveryBatch','AnyBatch'});
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterMode',"Config Error: CleaningFilterMode must be one of the following: 'Complete','Every Batch','Any Batch'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningPercentMissingPerFeature, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningPercentMissingPerFeature','Config Error: CleaningPercentMissingPerFeature value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleaningFilterMode2,{'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'});
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterMode2',"Config Error: CleaningMissingFilterMode must be one of the following: 'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterQCRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterQCRSD','Config Error: CleaningFilterQCRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterSampleRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterSampleRSD','Config Error: CleaningFilterSampleRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterDRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterDRatio','Config Error: CleaningFilterDRatio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleaningFilterBlankRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleaningFilterBlankRatio','Config Error: CleaningFilterBlankRatio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanedLogTransform, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedCleanedLogTransformValue','Config Error: CleanedLogTransform value must be logical (true/false)');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanedScaleMethod,{'None','Autoscale','Paretoscale'});
catch
    baseException = MException('QCRSC:UnexpectedCleanedScaleMethod',"Config Error: CleanedScaleMethod must be one of the following: 'None','Autoscale','Paretoscale'.");
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanedImputationMethod,{'KNNcolumn','KNNrow','blank20'});
catch
    baseException = MException('QCRSC:UnexpectedCleanedImputationMethod',"Config Error: CleanedImputationMethod must be one of the following: 'KNNcolumn','KNNrow','blank20'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanedImputationK, {'double'},{'scalar','integer','>=',1,'<=',20})
catch
    baseException = MException('QCRSC:UnexpectedCleanedImputationKvalue','Config Error: CleanedImputationK value must be a positive integer between 1 and 20');
    throw(baseException)
end



end

