function fig = plotStaticForest(FullForestStatsTable,useFullName,QCorREF)

FullForestStatsTable = FullForestStatsTable(1:874,:);


% ---------------------- Create Figure ---------------------------

fig = uifigure('Units', 'pixels', 'Position', [700, 50, 650, 900]);
fig.Scrollable = 'on';

x0 = 10;
y0 = 0;
hh = 900;
ww = 620;
buffer = 40;

plotPanel = uipanel(fig, 'Position', [x0, y0, x0+ww, y0+hh], 'BorderType', 'none');
ax1 = uiaxes(plotPanel,'Position', [x0, y0, x0+ww-buffer, y0+hh-buffer-20]);
disableDefaultInteractivity(ax1);
ax1.UserData = 1;

panelHeight = plotPanel.Position(4); 
vertpos = panelHeight - 30;

% ---------------------- Create Page Data ---------------------------

num = ceil(height(FullForestStatsTable)/100)-1;

for i = 1:num
    startIndex = (i - 1) * 100 + 1;
    endIndex = min(i * 100, height(FullForestStatsTable));
    forestPages{i} = FullForestStatsTable(startIndex:endIndex, :);
end
startIndex = endIndex+1;
forestPages{num+1} = FullForestStatsTable(startIndex:end, :);

%pageNumTxt = ['1/',num2str(num+1)];


countLabel = uilabel(plotPanel, ...
    'Position', [595 vertpos-25 100 22], ...
    'Text', '1/1', ...
    'FontSize',14, ...
    'FontColor','r');

% ---------------------- Plot Page ---------------------------

plotPage(forestPages,ax1,countLabel,QCorREF);

% ---------------------- User Interface Page ---------------------------


uilabel(plotPanel, ...
    'Position', [100 vertpos-1 60 22], ...
    'Text', 'File Name:');

ef = uieditfield(fig, 'text', ...
    'Position', [170 vertpos-1 120 22], ...
    'Value', 'ForestPlot.pdf','ValueChangedFcn',@(src,event) filenameChanged(src,event,fig));

uilabel(plotPanel, ...
    'Position', [490 vertpos-1 80 22], ...
    'Text', 'Label Width:');

ef2 = uieditfield(fig, 'numeric', ...
    'Position', [568 vertpos-1 30 22], ...
    'Value', 100,'ValueChangedFcn',@(src,event) labelwidthChanged(src,event,fig));

uibutton(plotPanel, ...
    'Text', 'Export Figure', ...
    'Position', [5, vertpos, 80, 22],'ButtonPushedFcn',@(src,event) ButtonPushed(src,event,ef.Value,dpi.Value,fig,ax1));
uibutton(plotPanel, ...
    'Text', 'Export Data', ...
    'Position', [5, vertpos-25, 80, 22],'ButtonPushedFcn',@(src,event) ButtonPushed2(src,event,TT,QCorREF,uieditfield,fig));

uibutton(plotPanel, ...
    'Text', 'PgUp', ...
    'Position', [505, vertpos-25, 40, 22],'ButtonPushedFcn',@(src,event) PgUpButtonPushed(src,event,ax1,forestPages,countLabel,QCorREF));

uibutton(plotPanel, ...
    'Text', 'PgDn', ...
    'Position', [550, vertpos-25, 40, 22],'ButtonPushedFcn',@(src,event) PgDnButtonPushed(src,event,ax1,forestPages,countLabel,QCorREF));





end

function plotPage(forestPages,ax1,countLabel,QCorREF)

    cla(ax1);
    currentPage = ax1.UserData;
    countLabel.Text = [num2str(currentPage),'/',num2str(numel(forestPages))];

    TT = forestPages{currentPage};
    
   switch QCorREF
        case 'QC'       
            sigCol = [0.85,0.1,0.1];
            tt = 'QC';
        case 'REF'       
            sigCol = [0.83,0.67,0.21];
            tt = 'Reference';
    end

    if currentPage == 1  
        PoolTable = TT(1:2,:);
        ForestTable = TT(3:end,:);
        n_studies = height(ForestTable);
        order = 1:n_studies;
        ForestTable = ForestTable(order,:);
        yticklabels(ax1,[{'Pooled Effect';''};ForestTable.ShortName(1:end)]);
        yrange = 3:n_studies+2;
        % Line of no effect (usually 0 for differences, 1 for ratios)
        line_of_no_effect = 0; 
        plot(ax1,[line_of_no_effect, line_of_no_effect], [0, n_studies+3], 'k--', 'LineWidth', 1.5);
        hold(ax1,"on");  
        yticks(ax1,1:n_studies+2);
        ylim(ax1,[0, n_studies+2]);
    else        
        ForestTable = TT;
        n_studies = height(ForestTable);
        order = 1:n_studies;
        ForestTable = ForestTable(order,:);
        yticklabels(ax1,ForestTable.ShortName(1:end));
        yrange = 1:n_studies;
        % Line of no effect (usually 0 for differences, 1 for ratios)
        line_of_no_effect = 0; 
        plot(ax1,[line_of_no_effect, line_of_no_effect], [0, n_studies], 'k--', 'LineWidth', 1.5);
        hold(ax1,"on");
        yticks(ax1,1:n_studies);
        ylim(ax1,[0, n_studies]);
    end

    
    
    
   
    
    xlim_upper = 100;
    xlim_lower = -20;
    
    maxMarkerSize = 100;
    minMarkerSize = 10;
    
    grey = [47,79,79]/255;
    
    
    if ismember('cleanPeaks', ForestTable.Properties.VariableNames)
        colCode = ForestTable.cleanPeaks+ForestTable.sig*10;
    else
        temp = ones(height(ForestTable),1);
        colCode = temp+ForestTable.sig*10;   
    end
    
    keys = [0, 1, 10, 11];
    valuesMFC = {[0,0,0], grey, [0,0,0], sigCol}; % black, blue, sigCol
    valuesLC = {[0,0,0,0.1], [grey,1], [0,0,0,0.1], [sigCol,1]}; % black, blue, sigCol
    valuesMFA = {0.1, 0.8, 0.1, 0.8}; % black, blue, sigCol
    
    mfcMap = dictionary(keys, valuesMFC);
    mfaMap = dictionary(keys, valuesMFA);
    
    mfc = cell2mat(mfcMap(colCode));
    mfa = cell2mat(mfaMap(colCode));
    
    ylinedata = [yrange;yrange];
    xlinedata = [ForestTable.lowerCI, ForestTable.upperCI]';
    for i = 1:4
        keep = colCode == keys(i);
        if any(keep)
            tempx = xlinedata(:,keep);
            tempy = ylinedata(:,keep);
            plot(ax1,tempx, tempy, '-', 'Color',valuesLC{i}, 'LineWidth', 1);
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
    s = scatter(ax1,ForestTable.meanDeltaCV, yrange, ms, 's','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfc);
    alpha(s,mfa);
    outofrange = ForestTable.meanDeltaCV > 100;
    yOOR = yrange(outofrange);
    xOOR = repmat(100,[length(yOOR),1]);
    msOOR = ms(outofrange);
    mfcOOR = mfc(outofrange,:);
    mfaOOR = mfa(outofrange,:);
    s2 = scatter(ax1,xOOR, yOOR, msOOR, '>','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfcOOR);
    alpha(s2,mfaOOR);
    outofrange = ForestTable.meanDeltaCV < -10;
    yOOR = yrange(outofrange);
    xOOR = repmat(-10,[length(yOOR),1]);
    msOOR = ms(outofrange);
    mfcOOR = mfc(outofrange,:);
    mfaOOR = mfa(outofrange,:);
    s3 = scatter(ax1,xOOR, yOOR, msOOR, '<','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfcOOR);
    alpha(s3,mfaOOR);

    
    
    % Plot formatting ---
    
    xlim(ax1,[xlim_lower, xlim_upper]);
    xlabel(ax1,{['% Improvement in ',tt,'-RSD (95% CI)'];''},"FontSize",12);
    ylabel(ax1,'');
    
    %yticks(ax1,'manual'); 
    % if useFullName
    %     yticklabels(ax1,[{'Pooled Effect';''};ForestTable.Name(1:end)]);
    % else
    %    yticklabels(ax1,[{'Pooled Effect';''};ForestTable.ShortName(1:end)]);
    %end
    ax1.FontUnits = 'points';
    ax1.YAxis.FontSize = 6;
    ax1.YAxis.FontName = 'Monaco';
    ax1.TickLength = [0.005, 0.025]; 
    set(ax1, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
    
    grid(ax1,'on');
    box(ax1,'on');
    ax1.Toolbar.Visible = 'off'; 
    ax1.XTick = xlim_lower:10:xlim_upper;
    
    if currentPage == 1

        plot(ax1,[xlim_lower, xlim_upper], [2, 2], 'k-', 'LineWidth', 0.75);

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
    end
    
    
    
    txt5 = sprintf('Unweighted %cRSD Forest Plot: (%s)',916,tt);
    
    title(ax1,txt5,FontSize=14);
    
    
end


function filenameChanged(src,~,fig)
    [~, name, ext] = fileparts(src.Value);
    if ~ismember(lower(ext),{'png', 'svg', 'pdf', 'jpg', 'tif'})
        uialert(fig,"Only {'png', 'svg', 'pdf', 'jpg', 'tif'} filetypes supported. Now set to '.png' ",'Warning','Icon','Warning');
        src.Value = [name,'.png'];
    end
end

function ButtonPushed(~,~,filename,dpi,fig,ax)

    if isfile(filename)
        selection = uiconfirm(fig,['Overwrite file ',filename,'?'],'Confirm DataTable Action','Icon','question');
        if strcmp(selection,'Cancel')
            return;
        end
    end
    try
        exportgraphics(ax,"scaledchart.pdf",Units="centimeters",Resolution=dpi,Height=29.7,PreserveAspectRatio="on",Padding="figure");
        exportgraphics(ax,"scaledchart.pdf",Units="centimeters",Resolution=dpi,Height=29.7,PreserveAspectRatio="on",Padding="figure",Append=true);
        %exportgraphics(fig,filename,'Resolution',dpi);
        uialert(fig,'Forest plot saved!','Success','Icon','success');
    catch
        uialert(fig,"Unable to save the figure",'Warning','Icon','Warning');
    end
    
    
end

function ButtonPushed2(~,~,TT,QCorREF,uieditfield,fig)
    [name,~] = fileparts(uieditfield.Value);
    filename = [name,'.csv'];
    Temp = TT(:,{'UID','Name','meanDeltaCV','lowerCI','upperCI','sig'});
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

function PgDnButtonPushed(~,~,ax1,forestPages,countLabel,QCorREF)
    if ax1.UserData == numel(forestPages)
        return;
    end
    ax1.UserData = ax1.UserData + 1;
    plotPage(forestPages,ax1,countLabel,QCorREF);
end

function PgUpButtonPushed(~,~,ax1,forestPages,countLabel,QCorREF)
    if ax1.UserData == 1
        return;
    end
    ax1.UserData = ax1.UserData - 1;
    plotPage(forestPages,ax1,countLabel,QCorREF);
end



