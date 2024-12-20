function [DataTable,FeatureTable] = load_dataXL(filename,options)

% This function loads and validates the Metabolomics DataFile and FeatureFile from an Excel Sheet:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Feature File: The first columns should contain the Feature Label matching the DataFile (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "table"

    arguments
       filename {mustBeFile,mustBeXLfile}
       options.DataSheet (1,:) char = 'Data'
       options.FeatureSheet (1,:) char = 'Features'
       options.replace_zero logical = true 
       options.fighandle = uifigure;
    end

DataSheet = options.DataSheet;
FeatureSheet = options.FeatureSheet;


d = uiprogressdlg(options.fighandle,'Title',['Importing ',filename]);
drawnow
steps = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD FEATURE SHEET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',FeatureSheet];
step = 1;
d.Value = step/steps;
FeatureTable = readtable(filename,'Sheet',FeatureSheet,'VariableNamingRule', 'preserve');
feature_list = FeatureTable.UID;



features = unique(feature_list);
if numel(features) ~= numel(feature_list)
    error(['All UIDs in ',FeatureSheet,' should be unique']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA SHEET
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',DataSheet];
step = 2;
d.Value = step/steps;

DataTable = readtable(filename,'Sheet',DataSheet,'VariableNamingRule', 'preserve');
list = DataTable.Properties.VariableNames;
temp = intersect(feature_list,list);

if numel(temp) ~= numel(feature_list)
    error(['The UID (Column Name) for each Feature in  ''',DataSheet,''' should exactly match the feature UIDs in ''',FeatureSheet,''' Remember that all UIDs should be unique']);
end

step = 3;
d.Value = step/steps;

if options.replace_zero == true
    X = DataTable{:,feature_list};
    zeros = X==0;
    if sum(zeros,'all') > 0
        disp(['Replacing ',num2str(sum(zeros,'all')), ' Zeros with NaNs']);
        X(zeros) = NaN;
        DataTable{:,feature_list} = X;
    end 
end
    

%DataTable = standardizeMissing(DataTable,{NaN,-99,'','.','NA','N/A'});

r = size(DataTable,1);
c = length(feature_list);
%display(['TOTAL SAMPLES: ',num2str(r),' TOTAL FEATURES: ',num2str(c)]);
d.Message = ['TOTAL SAMPLES: ',num2str(r),' TOTAL FEATURES: ',num2str(c)];
%disp('Done!');

pause(3);

close(d)

end

% Custom validation function
function mustBeXLfile(filename)
    %Test for whether file is an Excel file.
    [~,~,ext] = fileparts(filename); 
    if ~strcmp(ext,'.xlsx') && ~strcmp(ext,'.xls')
        eid = 'File:NotExcel';
        msg = ['"',filename,'" is not an Excel file'];
        throwAsCaller(MException(eid,msg))
    end
end
    
 

