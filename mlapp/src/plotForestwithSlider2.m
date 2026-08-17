function  plotForestwithSlider2(fig,ax,ax2,textBox,ForestTable,order,window_size,plotType)

%cla(ax);
%cla(ax2);
linkaxes([ax,ax2],'x');
PoolTable = ForestTable(1:2,:);
ForestTable = ForestTable(3:end,:);
ForestTable = ForestTable(order,:);

xlim_upper = 80;
xlim_lower = -10;
hold(ax2,"off");
hold(ax,"off");

switch plotType
    case 'QC'
        sigCol = [0.85,0.1,0.1];
        tt = 'qcRSD';
    case 'REF'
        sigCol = [0.83,0.67,0.21];
        tt = 'referenceRSD';
end



n_studies = height(ForestTable);

%textBox = uilabel(fig,'Position',[13,5,697,75],'BackgroundColor',[1 0.749 0.749],'Visible','off');

% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax,[line_of_no_effect, line_of_no_effect], [0, n_studies], 'k--', 'LineWidth', 1.5);
hold(ax,"on");

maxMarkerSize = 400;
minMarkerSize = 20;

if ismember('cleanPeaks', ForestTable.Properties.VariableNames)
    colCode = ForestTable.cleanPeaks+ForestTable.sig*10;
else
    temp = ones(height(ForestTable),1);
    colCode = temp+ForestTable.sig*10;   
end




keys = [0, 1, 10, 11];
valuesMFC = {[0,0,0], [0,0.2,1], [0,0,0], sigCol}; % black, blue, sigCol
valuesLC = {[0,0,0,0.1], [0,0.2,1,1], [0,0,0,0.1], [sigCol,1]}; % black, blue, sigCol
valuesMFA = {0.2, 1, 0.2, 1}; % black, blue, sigCol

mfcMap = dictionary(keys, valuesMFC);
lcMap = dictionary(keys, valuesLC);
mfaMap = dictionary(keys, valuesMFA);

mfc = cell2mat(mfcMap(colCode));
lc = cell2mat(lcMap(colCode));
mfa = cell2mat(mfaMap(colCode));

ylinedata = [2:n_studies+1;2:n_studies+1];
xlinedata = [ForestTable.lowerCI, ForestTable.upperCI]';
for i = 1:4
    keep = colCode == keys(i);
    if any(keep)
        tempx = xlinedata(:,keep);
        tempy = ylinedata(:,keep);
        plot(ax,tempx, tempy, '-', 'Color',valuesLC{i}, 'LineWidth', 1.5);
        keep = tempx(2,:) > xlim_upper;
        if any(keep)
            scatter(ax,xlim_upper, tempy(1,keep),50,valuesMFC{i},'filled','>','AlphaDataMapping','none','AlphaData',0.2,'MarkerFaceAlpha','flat','MarkerFaceColor','flat');
        end
        keep = tempx(1,:) < xlim_lower;
        if any(keep)
            scatter(ax,xlim_lower, tempy(1,keep),50,valuesMFC{i},'filled','<','AlphaDataMapping','none','AlphaData',0.2,'MarkerFaceAlpha','flat','MarkerFaceColor','flat');
        end
    end
end

%plot(ax,[ForestTable.lowerCI, ForestTable.upperCI]', temp, '-', 'Color', 'k', 'LineWidth', 1.5);
ms = minMarkerSize + (ForestTable.cvA * (maxMarkerSize - minMarkerSize)) / 100;
s = scatter(ax,ForestTable.meanDeltaCV, 2:n_studies+1, ms, 's','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfc,'ButtonDownFcn',@(src,event)MouseClick(src,event,textBox,ForestTable));
% s = scatter(ax,ForestTable.meanDeltaCV, 2:n_studies+1, ms, 's','ButtonDownFcn',@(src,event)MouseClick(src,event,textBox,ForestTable));
% s.MarkerFaceColor = 'flat';
% s.CData = mfc;
% s.AlphaDataMapping = "none";
alpha(s,mfa);

% Plot formatting ---
ylim(ax, [1, 1 + window_size]);
%ylim(ax,[0, n_studies+2]);
xlim(ax,[xlim_lower, xlim_upper]);
xlabel(ax,['Delta %RSD (After ',char(8211),' Before)']);
ylabel(ax,'');
yticks(ax,2:n_studies+1);
yticklabels(ax,ForestTable.ShortName(1:end));
ax.YAxis.FontSize = 8;
set(ax, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid(ax,'on');
box(ax,'on');


% Plot the Pooled Effect Diamond ---
% Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
X_diamond = [PoolTable.lowerCI(1), PoolTable.meanDeltaCV(1), PoolTable.upperCI(1), PoolTable.meanDeltaCV(1), PoolTable.lowerCI(1)];
X_diamondX = [PoolTable.lowerCI(2), PoolTable.meanDeltaCV(2), PoolTable.upperCI(2), PoolTable.meanDeltaCV(2), PoolTable.lowerCI(2)];
Y_diamond = [1, 1.5, 1, 0.5, 1];
%Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];

% Draw the diamond
fill(ax2,X_diamond, Y_diamond, 'k', 'FaceAlpha', 0, 'EdgeColor', 'k');
hold(ax2,"on");
plot(ax2,[line_of_no_effect, line_of_no_effect], [0, 2], 'k--', 'LineWidth', 1.5);
if PoolTable.sig(2)
    fill(ax2,X_diamondX, Y_diamond, sigCol, 'FaceAlpha', 0.5, 'EdgeColor', 'k','ButtonDownFcn',@(src,event)MouseClickPooled(src,textBox,PoolTable));
else
    fill(ax2,X_diamondX, Y_diamond, [0,0.2,1], 'FaceAlpha', 0.5, 'EdgeColor', 'k','ButtonDownFcn',@(src,event)MouseClickPooled(src,textBox,PoolTable));
end


xlim(ax2,[xlim_lower, xlim_upper]);
ax2.XTick = ax.XTick;
ax2.XAxis.TickLength = [0 0];
ylim(ax2,[0,2]);
yticks(ax2,1);
yticklabels(ax2,'Pooled Effect');
grid(ax2,'on');
box(ax2,'on');
ax2.PlotBoxAspectRatio = [20 1 1];
title(ax2,[tt,' : Unweighted Forest Plot']);

ax2.InnerPosition(1) = ax.InnerPosition(1);
ax2.InnerPosition(3) = ax.InnerPosition(3);
ax.ButtonDownFcn = @(src,event)MouseClick2(src,textBox);
ax2.ButtonDownFcn = @(src,event)MouseClick2(src,textBox);


if window_size <= n_studies
    min_y = 1;
    max_y = n_studies;
    slider_max = max_y - window_size + 1; 
    sliderstep = [(window_size+1)/n_studies, (window_size+1)/n_studies];
    
    fc = slider_max/(window_size);
    
    a = uicontrol('Parent', fig, ...
            'Style', 'slider', ...
            'Units', 'pixels', ...
            'Position', [15,120,25,460], ...
            'Min', min_y, ...
            'Max', slider_max, ...
            'Value', slider_max, ...  
            'SliderStep', sliderstep, ...
            'Callback', @(src, event) scroll_callback(src, ax, window_size));
end
%'SliderStep', [1, window_size], ...   
hold(ax,"off");
hold(ax2,"off");
end

function scroll_callback(slider_handle, target_axes, window_size)
    start_y = get(slider_handle, 'Max') - get(slider_handle, 'Value') + 1;
    %ylim(target_axes, [start_y, start_y + window_size]);
    ylim(target_axes, [start_y, start_y + window_size+1]);
end

function MouseClick(source,event,labelvariable,statsData)
       % if source.Parent.Children(1).UserData == -1
       %     delete(source.Parent.Children(1))
       % end

       childObjects = findobj(source.Parent.Parent, 'UserData', -1);
       delete(childObjects);

       idx = event.IntersectionPoint(2)-1;
       %idx = source.YData-1;
       hold(source.Parent,"on");
       scatter(source.Parent,statsData.meanDeltaCV(idx), idx+1, source.SizeData(idx) + 80, 'k', 'o', 'UserData',-1,'LineWidth',1.5);
       hold(source.Parent,"off");
       txt0 = sprintf('<b> SampleID:</b> %s: %s',statsData.UID{idx},statsData.Name{idx});
       txt1 = sprintf('\n<b> qcRSD (95%%CI):</b> %.2f%% (%.2f-%.2f) | <b>sampleRSD (95%%CI):</b> %.2f%% (%.2f-%.2f)', ...
       statsData.qcRSD(idx),statsData.qcRSDlower95CI(idx),statsData.qcRSDupper95CI(idx), ...
       statsData.sampleRSD(idx),statsData.sampleRSDlower95CI(idx),statsData.sampleRSDupper95CI(idx));
       if statsData.blankRatio == 0.1
             txt2 = sprintf('\n<b> dRatio:</b> %.2f%% | <b>blankRatio:</b> < 0.1%%',statsData.dRatio(idx));                
       else
             txt2 = sprintf('\n<b> dRatio:</b> %.2f%% | <b>blankRatio:</b> %.2f%%',statsData.dRatio(idx),statsData.blankRatio(idx));
       end
       txt3 = sprintf(' | <b>refRSD (95%%CI):</b> %.2f%% (%.2f-%.2f)',statsData.refRSD(idx),statsData.refRSDlower95CI(idx),statsData.refRSDupper95CI(idx));
       txt4 = sprintf(' | <b>qcMissing:</b> %.0f%% | <b>sampleMissing:</b> %.0f%%',statsData.qcMissingPerc(idx),statsData.sampleMissingPerc(idx));
       txt5 = sprintf('\n<b> %cRSD (95%%CI):</b> %.2f%% (%.2f-%.2f)',916,statsData.meanDeltaCV(idx),statsData.lowerCI(idx),statsData.upperCI(idx));
       
       if any(statsData.refRSD)
           labelvariable.Text = [txt0,txt1,txt3,txt2,txt4,txt5];
       else
           labelvariable.Text = [txt0,txt1,txt2,txt4,txt5];
       end
       switch source.CData(idx,2)
           case 0
               labelvariable.BackgroundColor = [0.9,0.9,0.9];
           case 0.2
               labelvariable.BackgroundColor = [124, 139, 245]/255; %blue
           case 0.1
               labelvariable.BackgroundColor = [252, 164, 168]/255; %red
           case 0.67
               labelvariable.BackgroundColor = [237, 214, 138]/255; %yellow
       end


       labelvariable.Visible = true;
end

function MouseClick2(source,labelvariable)
        childObjects = findobj(source.Parent.Parent, 'UserData', -1);
        delete(childObjects);
        labelvariable.Visible ="off";
end

function MouseClickPooled(source,labelvariable,statsData)
   
       childObjects = findobj(source.Parent.Parent, 'UserData', -1);
       delete(childObjects);

       hold(source.Parent,"on");
       scatter(source.Parent,statsData.meanDeltaCV(2), 1, 200, 'k', 'o', 'UserData',-1,'LineWidth',1.5);
       hold(source.Parent,"off");
       txt0 = sprintf('<b> Pooled Effect </b>');
       txt5 = sprintf('\n<b> %cRSD (95%%CI):</b> %.2f%% (%.2f-%.2f)',916,statsData.meanDeltaCV(2),statsData.lowerCI(2),statsData.upperCI(2));
           
       labelvariable.Text = [txt0,txt5];

       switch source.FaceColor(2)
           case 0.1
               labelvariable.BackgroundColor = [252, 164, 168]/255; %red
           case 0.67
               labelvariable.BackgroundColor = [237, 214, 138]/255; %yellow
           otherwise
               labelvariable.BackgroundColor = [124, 139, 245]/255; %blue
       end
       
       labelvariable.Visible = true;
end