function  plotForestwithSlider(fig,ax,ax2,textBox,ForestTable,window_size)

cla(ax);
cla(ax2);
linkaxes([ax,ax2],'x');
PoolTable = ForestTable(1:2,:);
ForestTable = ForestTable(3:end,:);

xlim_upper = 80;
xlim_lower = -10;


n_studies = height(ForestTable);

%textBox = uilabel(fig,'Position',[13,5,697,75],'BackgroundColor',[1 0.749 0.749],'Visible','off');

% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax,[line_of_no_effect, line_of_no_effect], [0, n_studies], 'k--', 'LineWidth', 1.5);
hold(ax,"on");

maxMarkerSize = 400;
minMarkerSize = 20;

% Plot Individual Study CIs and Effects ---
for i = 1:n_studies
    if ForestTable.cleanPeaks(i)
        if ForestTable.sig(i)
            mfc = [1,0.24,0.24];
            lc = [1,0.24,0.24];
            mfa = 1;
        else
            mfc = [0,0.2,1];
            lc = [0,0.2,1];
            mfa = 1;
        end
    else
        mfc = [0,0,0];
        lc = [0,0,0,0.1];
        mfa = 0.2;
    end
    % Plot confidence interval lines
    plot(ax,[ForestTable.lowerCI(i), ForestTable.upperCI(i)], [i+1, i+1], '-', 'Color', lc, 'LineWidth', 1.5);
    % Plot point estimates
    ms = minMarkerSize + (ForestTable.cvA(i) * (maxMarkerSize - minMarkerSize)) / 100;
    %plot(ax,ForestTable.meanDeltaCV(i), i+1, 's', 'Color', mfc,'MarkerFaceColor', mfc, 'MarkerSize', ms);
    f = scatter(ax,ForestTable.meanDeltaCV(i), i+1, ms, 's', 'Color', mfc,'MarkerFaceColor', mfc, 'MarkerEdgeAlpha', mfa, 'MarkerFaceAlpha', mfa,'ButtonDownFcn',@(src,event)MouseClick(src,textBox,ForestTable));
    % Plot outside limits
    if ForestTable.upperCI(i) > xlim_upper
        %plot(ax,xlim_upper, i+1, '>', 'Color', mfc, 'MarkerFaceColor', mfc, 'MarkerSize', 6);
        scatter(ax,xlim_upper, i+1, 40, '>', 'Color', mfc, 'MarkerFaceColor', mfc, 'MarkerEdgeAlpha', mfa, 'MarkerFaceAlpha', mfa);
    end
    if ForestTable.lowerCI(i) < xlim_lower
        %plot(ax,xlim_lower, i+1, '<', 'Color', mfc, 'MarkerFaceColor', mfc, 'MarkerSize', 6);
        scatter(ax,xlim_lower, i+1, 40, '<', 'Color', mfc, 'MarkerFaceColor', mfc, 'MarkerEdgeAlpha', mfa, 'MarkerFaceAlpha', mfa);
    end

end

% Plot formatting ---
ylim(ax, [1, 1 + window_size]);
%ylim(ax,[0, n_studies+2]);
xlim(ax,[xlim_lower, xlim_upper]);
xlabel(ax,['Delta %RSD (After ',char(8211),' Before)']);
ylabel(ax,'');
yticks(ax,2:n_studies+1);
yticklabels(ax,ForestTable.Name(1:end));
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
if PoolTable.sig(2)
    fill(ax2,X_diamondX, Y_diamond, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
else
    fill(ax2,X_diamondX, Y_diamond, 'b', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
end

xlim(ax2,[xlim_lower, xlim_upper]);
ax2.XTick = ax.XTick;
ax2.XAxis.TickLength = [0 0];
ylim(ax2,[0,2]);
yticks(ax2,1);
yticklabels(ax2,PoolTable.UID(1));
grid(ax2,'on');
box(ax2,'on');
ax2.PlotBoxAspectRatio = [20 1 1];
title(ax2,'Unweighted Forest Plot');

ax2.InnerPosition(1) = ax.InnerPosition(1);
ax2.InnerPosition(3) = ax.InnerPosition(3);


min_y = 1;
max_y = n_studies;
slider_max = max_y - window_size + 1; 

fc = slider_max/(window_size);

uicontrol('Parent', fig, ...
        'Style', 'slider', ...
        'Units', 'pixels', ...
        'Position', [15,120,25,460], ...
        'Min', min_y, ...
        'Max', slider_max, ...
        'Value', slider_max, ...
        'SliderStep', [.1, fc], ...
        'Callback', @(src, event) scroll_callback(src, ax, window_size));

ax.ButtonDownFcn = @(src,event)MouseClick2(src,textBox);

end

function scroll_callback(slider_handle, target_axes, window_size)
    start_y = get(slider_handle, 'Max') - get(slider_handle, 'Value') + 1;
    %ylim(target_axes, [start_y, start_y + window_size]);
    ylim(target_axes, [start_y, start_y + window_size+1]);
end

function MouseClick(source,labelvariable,statsData)
       if source.Parent.Children(1).UserData == -1
           delete(source.Parent.Children(1))
       end

       idx = source.YData-1;
       scatter(source.Parent,statsData.meanDeltaCV(idx), idx+1, source.SizeData + 80, 'k', 'o', 'UserData',-1,'LineWidth',1.5);
       txt0 = sprintf(' SampleID : %s : %s',statsData.UID{idx},statsData.Name{idx});
       % txt1 = sprintf('\n qcRSD (95%%CI) : %.2f%% (%.2f-%.2f) | sampleRSD (95%%CI) : %.2f%% (%.2f-%.2f)', ...
       % statsData.qq,statsData.qql,statsData.qqu, ...
       % statsData.ss,statsData.ssl,statsData.ssu);
       % if statsData.bb == 0.1
       %      txt2 = sprintf('\n dRatio : %.2f%% | blankRatio : < 0.1%%',statsData.dd);                
       % else
       %      txt2 = sprintf('\n dRatio : %.2f%% | blankRatio : %.2f%%',statsData.dd,statsData.bb);
       % end
       % txt3 = sprintf(' | refRSD (95%%CI) : %.2f%% (%.2f-%.2f)',statsData.rr,statsData.rrl,statsData.rru);
       % txt4 = sprintf('\n qcMissing : %.0f%% | sampleMissing : %.0f%%',statsData.qqm,statsData.ssm);
       % txt5 = sprintf(' (filtered on Batch %d)',statsData.bestbatch);
       % if statsData.bestbatch ~= -1
       %     txt0 = [txt0,txt5];
       % end
       % if any(app.PlotDataTable.Reference)
       %     labelvariable.Text = [txt0,txt1,txt3,txt2,txt4];
       % else
       %     labelvariable.Text = [txt0,txt1,txt2,txt4];
       % end
       labelvariable.Text = txt0;
       labelvariable.Visible = true;
end

function MouseClick2(source,labelvariable)
    if source.Parent.Children(end).Children(1).UserData == -1
       delete(source.Parent.Children(end).Children(1))
   end
    labelvariable.Visible ="off";
    % if ~isempty(app.ifig2)
    %     for i=1:length(app.ifig2)          
    %         delete(app.ifig2(i));                 
    %     end
    % end
end