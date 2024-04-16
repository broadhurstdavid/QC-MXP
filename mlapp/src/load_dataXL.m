function [DataTable,PeakTable] = load_dataXL(filename,options)

% This function loads and validates the Metabolomics DataFile and PeakFile from an Excel Sheet:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Peak File: The first columns should contain the Peak Label matching the DataFile (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "table"

    arguments
       filename {mustBeFile,mustBeXLfile}
       options.DataSheet (1,:) char = 'Data'
       options.PeakSheet (1,:) char = 'Peak'
       options.replace_zero logical = true 
       options.fighandle = uifigure;
    end

DataSheet = options.DataSheet;
PeakSheet = options.PeakSheet;


d = uiprogressdlg(options.fighandle,'Title',['Importing ',filename]);
drawnow
steps = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PEAK FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',PeakSheet];
step = 1;
d.Value = step/steps;
PeakTable = readtable(filename,'Sheet',PeakSheet,'VariableNamingRule', 'preserve');
peak_list = PeakTable.UID;



peaks = unique(peak_list);
if numel(peaks) ~= numel(peak_list)
    error(['All UIDs in ',PeakSheet,' should be unique']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',DataSheet];
step = 2;
d.Value = step/steps;

DataTable = readtable(filename,'Sheet',DataSheet,'VariableNamingRule', 'preserve');
list = DataTable.Properties.VariableNames;
temp = intersect(peak_list,list);

if numel(temp) ~= numel(peak_list)
    error(['The UID (Column Name) for each Peak in  ''',DataSheet,''' should exactly match the peak UIDs in ''',PeakSheet,''' Remember that all UIDs should be unique']);
end

step = 3;
d.Value = step/steps;

if options.replace_zero == true
    X = DataTable{:,peak_list};
    zeros = X==0;
    if sum(zeros,'all') > 0
        disp(['Replacing ',num2str(sum(zeros,'all')), ' Zeros with NaNs']);
        X(zeros) = NaN;
        DataTable{:,peak_list} = X;
    end 
end
    

%DataTable = standardizeMissing(DataTable,{NaN,-99,'','.','NA','N/A'});

r = size(DataTable,1);
c = length(peak_list);
%display(['TOTAL SAMPLES: ',num2str(r),' TOTAL PEAKS: ',num2str(c)]);
d.Message = ['TOTAL SAMPLES: ',num2str(r),' TOTAL PEAKS: ',num2str(c)];
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
    
 

