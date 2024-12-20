function [DataTable,FeatureDictionary] = validatingDataFeatureTables(DataTable,FeatureDictionary,options)

    arguments
       DataTable
       FeatureDictionary
       options.fighandle = uifigure;
       options.ColumnWarningFlag = true;
    end

peakHeader = FeatureDictionary.Properties.VariableNames;

if ~all(ismember({'UID','Name'},peakHeader))
    ME = MException('TidyData:FeatureDictionaryError','FeatureDictionary must contain columns ''UID'' & ''Name''');
    throw(ME);
end

peakList = FeatureDictionary.UID;
peaks = unique(peakList);
if numel(peaks) ~= numel(peakList)
    ME = MException('TidyData:FeatureDictionaryError','All UIDs in the PeakSheet must be unique.');
    throw(ME);
end

dataHeader = DataTable.Properties.VariableNames;
temp = intersect(peakList,dataHeader);
if numel(temp) ~= numel(peakList)
    ME = MException('TidyData:DataTableError','The UID (Column Name) for each Peak in the DataSheet should be unique and exactly match the UID in the PeakSheet.');
    throw(ME);
end

if ~all(ismember({'Order','Batch','SampleID','SampleType'},dataHeader))
    ME = MException('TidyData:DataTableError','DataTable must contain columns ''SampleID'', ''SampleType'', ''Order'', & ''Batch''');
    throw(ME);
end

if isnumeric(DataTable.SampleID)
    DataTable.SampleID = arrayfun(@(x) {num2str(x)},DataTable.SampleID);
end

DataTable = sortrows(DataTable,{'Batch','Order'});

try
    validateattributes(DataTable.Order,{'numeric'},{'integer','increasing'})
catch
    baseException = MException('TidyData:QCRSCDataTableError','DataTable ''Order'' column must contain unique increasing integer values matching to increasing batch number.');
    throw(baseException)
end


try
    validateattributes(DataTable.Batch,{'numeric'},{'integer','nonnan'})
catch
    baseException = MException('QCRSC:DataTableError','DataTable ''Batch'' column must contain integer values and no missing values');
    throw(baseException)
end

try
    mustBeMember(DataTable.SampleType,{'Sample','QC','Blank','Reference'});
catch
    baseException = MException('QCRSC:QCRSCDataTableError','DataTable ''SampleType'' column values must be one of the following: ''Sample'',''QC'',''Blank'', or ''Reference''');
    throw(baseException)
end

if options.ColumnWarningFlag
    if any(ismember({'QC','Reference','Blank','Sample'},dataHeader))
           selection = uiconfirm(options.fighandle,'Any columns labelled ''QC'',''Reference'',''Blank'' or ''Sample'' will be overwritten','Confirm DataTable Action','Icon','warning');
           if strcmp(selection,'Cancel')
               baseException = MException('QCRSC:DataTableError','Remove or rename any columns labelled: ''QC'',''Reference'',''Blank'' or ''Sample'' and retry');
               throw(baseException)
           end
    end
end
  
DataTable.QC = ismember(DataTable.SampleType,'QC');
DataTable.Blank = ismember(DataTable.SampleType,'Blank');
DataTable.Reference = ismember(DataTable.SampleType,'Reference');
DataTable.Sample = ~DataTable.QC & ~DataTable.Blank & ~DataTable.Reference;

maxNumQCperBatch = checkNumberInBatch(DataTable,'QC');

if maxNumQCperBatch <= 3
    res = uiconfirm(options.fighandle,{'There has to be 3 or more QCs per batch for this data to be valid for QC assessment.';'You can perform Sample correction but the interactive explorer will be disabled.';'Do you wish to proceed?'},'Confirm Action','Options',{'Yes','No'});
            if strcmp(res,'No')
                baseException = MException('QCRSC:DataTableError','There has to be 3 or more QCs per batch for this data to be valid for QC assessment!');
                throw(baseException)
            end 
    %baseException = MException('QCRSC:DataTableError','There has to be 3 or more QCs per batch for this data to be valid for QC assessment!');
    %throw(baseException)
end



DataTable = movevars(DataTable,{'SampleType','Order','Batch','QC','Blank','Reference','Sample'},'After','SampleID');

%DataTable = movevars(DataTable,'SampleID','Before',1);
%DataTable = movevars(DataTable,{'SampleType','Order','Batch','QC','Blank','Reference','Sample'},'After','SampleID');


end

