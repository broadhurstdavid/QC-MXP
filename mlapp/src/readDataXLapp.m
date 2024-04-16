    function [DataTable,PeakTable] = readDataXLapp(filename,options)

% This function loads and validates the Metabolomics DataFile and PeakFile from an Excel Sheet:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Peak File: The first columns should contain the Peak Label matching the DataFile (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "table"

    arguments
       filename
       options.DataSheet (1,:) char = 'Data'
       options.PeakSheet (1,:) char = 'Peak'
       options.fighandle = uifigure;
    end

DataSheet = options.DataSheet;
PeakSheet = options.PeakSheet;


d = uiprogressdlg(options.fighandle,'Title',['Importing ',filename]);
drawnow
steps = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PEAK FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',PeakSheet];
step = 1;
d.Value = step/steps;
PeakTable = readtable(filename,'Sheet',PeakSheet,'VariableNamingRule','preserve');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',DataSheet];
step = 2;
d.Value = step/steps;

DataTable = readtable(filename,'Sheet',DataSheet,'VariableNamingRule','preserve');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALIDATING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = 'Vaildating Data';
step = 3;
d.Value = step/steps;

[DataTable,PeakTable] = validatingDataPeakTables(DataTable,PeakTable,fighandle = options.fighandle);

step = 4;
d.Value = step/steps;

r = size(DataTable,1);
c = height(PeakTable);

d.Message = ['TOTAL SAMPLES: ',num2str(r),' TOTAL PEAKS: ',num2str(c)];


pause(3);

close(d)

end


    
 

