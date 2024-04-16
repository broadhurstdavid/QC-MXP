function [DataTable,PeakTable] = readDataCSVapp(DataFilename,PeakFilename,options)

% This function loads and validates the Metabolomics DataFile and PeakFile from an Excel Sheet:
% Metabolite IDs must start with 'M' ... best to use M1 M2 M3 M4 etc. 
% Remaining columns are assumed to be user specific meta data and are ignored. 
% Peak File: The first columns should contain the Peak Label matching the DataFile (M1 M2 .. )
% The remaining columns can contain anything you like. Statistics will be added to this "table"

    arguments
       DataFilename (1,:) char 
       PeakFilename (1,:) char
       options.fighandle = uifigure;
    end




d = uiprogressdlg(options.fighandle,'Title','Importing CSV files');
drawnow
steps = 4;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD PEAK FILE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

d.Message = ['Loading PeakTable file: ',PeakFilename];
step = 1;
d.Value = step/steps;
PeakTable = readtable(PeakFilename,'VariableNamingRule', 'preserve');
peakList = PeakTable.UID;


peaks = unique(peakList);
if numel(peaks) ~= numel(peakList)
    error(['All Peak Names in ',PeakSheet,' should be unique']);
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


    
 

