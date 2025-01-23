    function [DataTable,FeatureTable] = readDataXLapp(filename,options)

% This function loads and validates the Metabolomics Data Sheet and Feature Table from an Excel Sheet:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Feature Table: The first columns should contain the Feature UID matching the DataSheet (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "Table"

    arguments
       filename
       options.DataSheet (1,:) char = 'Data'
       options.FeatureSheet (1,:) char = 'Features'
       options.fighandle = uifigure;
    end

DataSheet = options.DataSheet;
FeatureSheet = options.FeatureSheet;


d = uiprogressdlg(options.fighandle,'Title',['Importing ',filename]);
drawnow
steps = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PEAK FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Excel Sheet: ',FeatureSheet];
step = 1;
d.Value = step/steps;
FeatureTable = readtable(filename,'Sheet',FeatureSheet,'VariableNamingRule','preserve');

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

[DataTable,FeatureTable] = validatingDataFeatureTables(DataTable,FeatureTable,fighandle = options.fighandle);

step = 4;
d.Value = step/steps;

r = size(DataTable,1);
c = height(FeatureTable);

d.Message = ['TOTAL SAMPLES: ',num2str(r),' TOTAL FEATURES: ',num2str(c)];


pause(3);

close(d)

end


    
 

