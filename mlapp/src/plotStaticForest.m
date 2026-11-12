function fig = plotStaticForest(FullForestStatsTable,useFullName,QCorREF)

order = 1:height(FullForestStatsTable)-2;

switch QCorREF
    case 'QC'       
        sigCol = [0.85,0.1,0.1];
        tt = 'qcRSD';
    case 'REF'       
        sigCol = [0.83,0.67,0.21];
        tt = 'Reference';
end

PoolTable = FullForestStatsTable(1:2,:);
ForestTable = FullForestStatsTable(3:end,:);
ForestTable = ForestTable(order,:);

n_studies = height(ForestTable);

fig = uifigure('Position', [700, 300, 650, 600]);
fig.Scrollable = 'on';

x0 = 10;
y0 = 0;
hh = 1000;
ww = 620;
buffer = 40;

plotPanel = uipanel(fig, 'Position', [x0, y0, x0+ww, x0+hh], 'BorderType', 'none');

ax1 = uiaxes(plotPanel, 'Position', [x0, y0, x0+ww-buffer, x0+hh-buffer]);
disableDefaultInteractivity(ax1);


% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax1,[line_of_no_effect, line_of_no_effect], [0, n_studies+3], 'k--', 'LineWidth', 1.5);
hold(ax1,"on");

xlim_upper = 100;
xlim_lower = -20;

maxMarkerSize = 400;
minMarkerSize = 20;

if ismember('cleanPeaks', ForestTable.Properties.VariableNames)
    colCode = ForestTable.cleanPeaks+ForestTable.sig*10;
else
    temp = ones(height(ForestTable),1);
    colCode = temp+ForestTable.sig*10;   
end

%green = [46,139,87]/255;
grey = [47,79,79]/255;

keys = [0, 1, 10, 11];
%valuesMFC = {[0,0,0], [0,0.2,1], [0,0,0], sigCol}; % black, blue, sigCol
valuesMFC = {[0,0,0], grey, [0,0,0], sigCol}; % black, blue, sigCol
%valuesLC = {[0,0,0,0.1], [0,0.2,1,1], [0,0,0,0.1], [sigCol,1]}; % black, blue, sigCol
valuesLC = {[0,0,0,0.1], [grey,1], [0,0,0,0.1], [sigCol,1]}; % black, blue, sigCol
valuesMFA = {0.1, 1, 0.1, 1}; % black, blue, sigCol

mfcMap = dictionary(keys, valuesMFC);
lcMap = dictionary(keys, valuesLC);
mfaMap = dictionary(keys, valuesMFA);

mfc = cell2mat(mfcMap(colCode));
%lc = cell2mat(lcMap(colCode));
mfa = cell2mat(mfaMap(colCode));

ylinedata = [3:n_studies+2;3:n_studies+2];
xlinedata = [ForestTable.lowerCI, ForestTable.upperCI]';
for i = 1:4
    keep = colCode == keys(i);
    if any(keep)
        tempx = xlinedata(:,keep);
        tempy = ylinedata(:,keep);
        plot(ax1,tempx, tempy, '-', 'Color',valuesLC{i}, 'LineWidth', 1.5);
        keep = tempx(2,:) > xlim_upper;
        if any(keep)
            scatter(ax1,xlim_upper, tempy(1,keep),50,valuesMFC{i},'filled','>','AlphaDataMapping','none','AlphaData',0.2,'MarkerFaceAlpha','flat','MarkerFaceColor','flat');
        end
        keep = tempx(1,:) < xlim_lower;
        if any(keep)
            scatter(ax1,xlim_lower, tempy(1,keep),50,valuesMFC{i},'filled','<','AlphaDataMapping','none','AlphaData',0.2,'MarkerFaceAlpha','flat','MarkerFaceColor','flat');
        end
    end
end

ms = minMarkerSize + (ForestTable.cvA * (maxMarkerSize - minMarkerSize)) / 100;
s = scatter(ax1,ForestTable.meanDeltaCV, 3:n_studies+2, ms, 's','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfc);
alpha(s,mfa);

% Plot formatting ---
% %ylim(ax1, [1, 1 + window_size]);
% %ylim(ax,[0, n_studies+2]);
xlim(ax1,[xlim_lower, xlim_upper]);
xlabel(ax1,['% Improvement in ',tt,' RSD (95% CI)']);
ylabel(ax1,'');
yticks(ax1,1:n_studies+2);
if useFullName
    yticklabels(ax1,[{'Pooled Effect';''};ForestTable.Name(1:end)]);
else
    yticklabels(ax1,[{'Pooled Effect';''};ForestTable.ShortName(1:end)]);
end
ax1.YAxis.FontSize = 8;
ax1.YAxis.FontName = 'Monaco';
ax1.TickLength = [0.005, 0.025]; 
set(ax1, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid(ax1,'on');
box(ax1,'on');
ax1.Toolbar.Visible = 'off';
plot(ax1,[xlim_lower, xlim_upper], [2, 2], 'k-', 'LineWidth', 0.75);
ax1.XTick = [xlim_lower:10:xlim_upper];


% Plot the Pooled Effect Diamond ---
% Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
X_diamond = [PoolTable.lowerCI(1), PoolTable.meanDeltaCV(1), PoolTable.upperCI(1), PoolTable.meanDeltaCV(1), PoolTable.lowerCI(1)];
X_diamondX = [PoolTable.lowerCI(2), PoolTable.meanDeltaCV(2), PoolTable.upperCI(2), PoolTable.meanDeltaCV(2), PoolTable.lowerCI(2)];
Y_diamond = [1, 1.5, 1, 0.5, 1];
%Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];

% Draw the diamond
fill(ax1,X_diamond, Y_diamond, 'k', 'FaceAlpha', 0, 'EdgeColor', 'k');
hold(ax1,"on");
%plot(ax1,[line_of_no_effect, line_of_no_effect], [0, 2], 'k--', 'LineWidth', 1.5);
if PoolTable.sig(2)
    fill(ax1,X_diamondX, Y_diamond, sigCol, 'FaceAlpha', 0.5, 'EdgeColor', 'k','ButtonDownFcn',@(src,event)app.MouseClickPooled(src,PoolTable));
else
    fill(ax1,X_diamondX, Y_diamond, [0,0.2,1], 'FaceAlpha', 0.5, 'EdgeColor', 'k','ButtonDownFcn',@(src,event)app.MouseClickPooled(src,PoolTable));
end



txt5 = sprintf('Unweighted %cRSD Forest Plot: (%s)',916,tt);

title(ax1,txt5);

panelHeight = plotPanel.Position(4); 

vertpos = panelHeight - 30;

ef = uieditfield(fig, 'text', ...
    'Position', [330 vertpos-1 120 22], ...
    'Value', 'ForestPlot.png','ValueChangedFcn',@(src,event) filenameChanged(src,event,fig));

uicheckbox(plotPanel, ...
    'Text', 'Expand Y-labels', ...
    'Position', [500, vertpos, 120, 22], ...
    'Value', useFullName,'ValueChangedFcn', @(src, event) switchChangedCallback(src,event,ax1,ForestTable));


uilabel(plotPanel, ...
    'Text', 'dpi', ...
    'HorizontalAlignment', 'right', ...
    'Position', [90 vertpos 20 22]);

dpi = uieditfield(plotPanel, 'numeric', ...
    'Position', [115 vertpos 50 22], ...
    'Value', 300, ...                     % Default integer value
    'RoundFractionalValues', 'on', ...    % Forces fractional inputs to round to integers
    'ValueDisplayFormat', '%d'); 

uilabel(fig, ...
    'Position', [270 vertpos-1 60 22], ...
    'Text', 'File Name:');

uidropdown(plotPanel, ...
    'Position', [180, vertpos, 70, 22], ...                     % [left, bottom, width, height]
    'Items', {' PNG', ' SVG', ' PDF', ' JPG', ' TIF'}, ...        % Labels displayed to the user
    'ItemsData', {'png', 'svg', 'pdf', 'jpg', 'tif'}, ...      % Underlying code/values for each label
    'ValueChangedFcn', @(src, event) dropdownCallback(src,event,ef));

uibutton(plotPanel, ...
    'Text', 'Export Figure', ...
    'Position', [5, vertpos, 80, 22],'ButtonPushedFcn',@(src,event) ButtonPushed(src,event,ef.Value,dpi.Value,fig));
uibutton(plotPanel, ...
    'Text', 'Export Data', ...
    'Position', [5, vertpos-25, 80, 22],'ButtonPushedFcn',@(src,event) ButtonPushed2(src,event,FullForestStatsTable,QCorREF,uieditfield,fig));



function switchChangedCallback(~, event,ax,ForestTable)
    val = event.Value; % 1 (checked) or 0 (unchecked)
    if val
        yticklabels(ax,[{'Pooled Effect';''};ForestTable.Name(1:end)]);
    else
        yticklabels(ax,[{'Pooled Effect';''};ForestTable.ShortName(1:end)]);
    end
end

function dropdownCallback(src,~,uieditfield)
    [~, name] = fileparts(uieditfield.Value);
    switch src.Value
        case 'svg'
            uieditfield.Value = [name,'.svg'];
        case 'png'
            uieditfield.Value = [name,'.png'];
        case 'pdf'
            uieditfield.Value = [name,'.pdf'];
        case 'jpg'
            uieditfield.Value = [name,'.jpg'];
        case 'tif'
            uieditfield.Value = [name,'.tif'];
        otherwise
            uieditfield.Value = [name,'.png'];
    end

end

function filenameChanged(src,~,fig)
    [~, name, ext] = fileparts(src.Value);
    if ~ismember(lower(ext),{'png', 'svg', 'pdf', 'jpg', 'tif'})
        uialert(fig,"Only {'png', 'svg', 'pdf', 'jpg', 'tif'} filetypes supported. Now set to '.png' ",'Warning','Icon','Warning');
        src.Value = [name,'.png'];
    end
end



function ButtonPushed(~,~,filename,dpi,fig)

    if isfile(filename)
        selection = uiconfirm(fig,['Overwrite file ',filename,'?'],'Confirm DataTable Action','Icon','question');
        if strcmp(selection,'Cancel')
            return;
        end
    end
    try
        exportgraphics(fig,filename,'Resolution',dpi);
        uialert(fig,'Forest plot saved!','Success','Icon','success');
    catch
        uialert(fig,"Unable to save the figure",'Warning','Icon','Warning');
    end
    
    
end

function ButtonPushed2(~,~,FullForestStatsTable,QCorREF,uieditfield,fig)
    [name,~] = fileparts(uieditfield.Value);
    filename = [name,'.csv'];
    Temp = FullForestStatsTable(:,{'UID','Name','meanDeltaCV','lowerCI','upperCI','sig'});
    Temp(1,:) = [];
    Temp.UID{1} = 'PE';
    Temp.Name{1} = 'PooledEffect';

    if QCorREF        
        Temp.Properties.VariableNames = {'UID','Name','meanDeltaCV_QC','lowerCI_QC','upperCI_QC','sig_QC'};
    else
        Temp.Properties.VariableNames = {'UID','Name','meanDeltaCV_REF','lowerCI_REF','upperCI_REF','sig_REF'};        
    end
    try
        writetable(T,filename);
        uialert(fig,'Forest plot data saved as a csv file!','Success','Icon','success');
    catch
        uialert(fig,"Unable to save the figure data",'Warning','Icon','Warning');
    end

end

end

