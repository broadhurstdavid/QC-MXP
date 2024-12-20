function [DataTable,FeatureTable] = readDataCSVapp(DataFilename,FeatureFilename,options)

% This function loads and validates the Metabolomics Data and Feature CSV file:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Feature File: The first columns should contain the Peak Label matching the DataFile (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "table"

    arguments
       DataFilename (1,:) char 
       FeatureFilename (1,:) char
       options.fighandle = uifigure;
    end




d = uiprogressdlg(options.fighandle,'Title','Importing CSV files');
drawnow
steps = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PEAK FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading Feature Dictionary file: ',FeatureFilename];
step = 1;
d.Value = step/steps;
FeatureTable = readtable(FeatureFilename,'VariableNamingRule', 'preserve');
peakList = FeatureTable.UID;


peaks = unique(peakList);
if numel(peaks) ~= numel(peakList)
    error(['All Feature Names in ',FeatureFilename,' should be unique']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading DataTable file: ',DataFilename];
step = 2;
d.Value = step/steps;

DataTable = readtable(DataFilename,'VariableNamingRule', 'preserve');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% VALIDATING DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = 'Validating.';
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


    
 

