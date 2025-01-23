function baseConfig = validateConfig(baseConfig)

defaultFieldnames = [
  {'WorkingDirectory'} 
  {'FileType'}
  {'ProjectName'}
  {'DataTable'}
  {'FeatureTable'}
  {'MissingQCPreFilterMode'}
  {'MissingQCPreFilterPercentage'} 
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
  {'CleanMissingSampleFilterMode'}
  {'CleanMissingSampleFilterPercentage'}
  {'CleanFilterBankMode'}
  {'CleanFilterQCRSD'}
  {'CleanFilterSampleRSD'}
  {'CleanFilterDRatio'}
  {'CleanFilterBlankRatio'}
  {'CleanFileSuffix'}
  {'CleanLogTransform'}
  {'CleanScaleMethod'}
  {'CleanImputationMethod'}
  {'CleanImputationK'}];

baseFieldnames = fieldnames(baseConfig);

if ~isequal(defaultFieldnames,baseFieldnames)
    ME = MException('QCRSC:MismatchConfigStruct','Config Error: Incomplete or mislabled configuration structure');
    throw(ME);
end

try
    validateattributes(baseConfig.WorkingDirectory,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedWorkingDirectory','Config Error: WorkingDirectory value must be text');
    throw(baseException)
end 

try
    mustBeMember(baseConfig.FileType,{'csv','xlsx',''});
catch
    baseException = MException('QCRSC:UnexpectedCongigFileType',"Config Error: FileType must be either 'xlsx' or 'csv'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.ProjectName,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedProjectName','Config Error: ProjectName value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.DataTable,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedDataTable','Config Error: DataTable value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.FeatureTable,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedFeatureTable','Config Error: FeatureTable value must be text');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanFileSuffix,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedCleanFileSuffix','Config Error: CleanFileSuffix value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.CorrectedFileSuffix,{'char'},{'scalartext'})
catch
    baseException = MException('QCRSC:UnexpectedCorrectedFileSuffix','Config Error: CorrectedFileSuffix value must be text');
    throw(baseException)
end 

try
    validateattributes(baseConfig.MissingQCPreFilterPercentage, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedMissingQCPreFilterPercentageValue','Config Error: MissingQCPreFilterPercentageValue value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.MissingQCPreFilterMode,{'Complete','EveryBatch','AnyBatch'});
catch
    baseException = MException('QCRSC:UnexpectedMissingQCPreFilterMode',"Config Error: MissingQCPreFilterMode must be one of the following: 'Complete','Every Batch','Any Batch'.");
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
    mustBeMember(baseConfig.CleanMissingSampleFilterMode,{'Complete','EveryBatch','AnyBatch'});
catch
    baseException = MException('QCRSC:UnexpectedCleanMissingSampleFilterMode',"Config Error: CleanMissingSampleFilterMode must be one of the following: 'Complete','Every Batch','Any Batch'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanMissingSampleFilterPercentage, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleanMissingSampleFilterPercentage','Config Error: CleanMissingSampleFilterPercentage value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanFilterBankMode,{'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'});
catch
    baseException = MException('QCRSC:UnexpectedCleanFilterBankMode',"Config Error: CleanMissingFilterMode must be one of the following: 'Complete','Max qcRSD','Max dRatio', 'Median qcRSD','Median dRatio', 'Min qcRSD', 'Min dRatio'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanFilterQCRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleanFilterQCRSD','Config Error: CleanFilterQCRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanFilterSampleRSD, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleanFilterSampleRSD','Config Error: CleanFilterSampleRSD value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanFilterDRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleanFilterDRatio','Config Error: CleanFilterDRatio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanFilterBlankRatio, {'double'},{'scalar','integer','>=',0,'<=',100})
catch
    baseException = MException('QCRSC:UnexpectedCleanFilterBlankRatio','Config Error: CleanFilterBlankRatio value must be a positive integer between 0 and 100');
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanLogTransform, {'logical'},{'scalar'})
catch
    baseException = MException('QCRSC:UnexpectedCleanLogTransformValue','Config Error: CleanLogTransform value must be logical (true/false)');
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanScaleMethod,{'MeanCenter','Autoscale','Paretoscale'});
catch
    baseException = MException('QCRSC:UnexpectedCleanScaleMethod',"Config Error: CleanScaleMethod must be one of the following: 'None','Autoscale','Paretoscale'.");
    throw(baseException)
end

try
    mustBeMember(baseConfig.CleanImputationMethod,{'KNNcolumn','KNNrow','blank20'});
catch
    baseException = MException('QCRSC:UnexpectedCleanImputationMethod',"Config Error: CleanImputationMethod must be one of the following: 'KNNcolumn','KNNrow','blank20'.");
    throw(baseException)
end

try
    validateattributes(baseConfig.CleanImputationK, {'double'},{'scalar','integer','>=',1,'<=',20})
catch
    baseException = MException('QCRSC:UnexpectedCleanImputationKvalue','Config Error: CleanImputationK value must be a positive integer between 1 and 20');
    throw(baseException)
end



end

