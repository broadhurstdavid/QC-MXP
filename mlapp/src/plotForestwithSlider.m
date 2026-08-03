function  plotForestwithSlider(fig,ax,ax2,ForestTable,window_size)

cla(ax);
cla(ax2);
linkaxes([ax,ax2],'x');
PoolTable = ForestTable(1,:);
ForestTable = ForestTable(2:end,:);

xlim_upper = 80;
xlim_lower = -10;


n_studies = height(ForestTable);

% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax,[line_of_no_effect, line_of_no_effect], [0, n_studies], 'k--', 'LineWidth', 1.5);
hold(ax,"on");

maxMarkerSize = 30;
minMarkerSize = 4;

% Plot Individual Study CIs and Effects ---
for i = 1:n_studies
    % Plot confidence interval lines
    plot(ax,[ForestTable.lowerCI(i), ForestTable.upperCI(i)], [i+1, i+1], 'b-', 'LineWidth', 1.5);
    % Plot point estimates
    ms = minMarkerSize + (ForestTable.cvA(i) * (maxMarkerSize - minMarkerSize)) / 100;
    plot(ax,ForestTable.meanDeltaCV(i), i+1, 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', ms);
    % Plot outside limits
    if ForestTable.upperCI(i) > xlim_upper
        plot(ax,xlim_upper, i+1, 'b>', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
    end
    if ForestTable.lowerCI(i) < xlim_lower
        plot(ax,xlim_lower, i+1, 'b<', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
    end

end

% Plot formatting ---
ylim(ax, [1, 1 + window_size]);
%ylim(ax,[0, n_studies+2]);
xlim(ax,[xlim_lower, xlim_upper]);
xlabel(ax,['Delta RSD (After ',char(8211),' Before)']);
ylabel(ax,'');
yticks(ax,2:n_studies+1);
yticklabels(ax,ForestTable.Name(1:end));
set(ax, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid(ax,'on');
box(ax,'on');
hold(ax,"on");

% Plot the Pooled Effect Diamond ---
% Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
X_diamond = [ForestTable.lowerCI(1), ForestTable.meanDeltaCV(1), ForestTable.upperCI(1), ForestTable.meanDeltaCV(1), ForestTable.lowerCI(1)];
Y_diamond = [1, 1.5, 1, 0.5, 1];
%Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];

% Draw the diamond
fill(ax2,X_diamond, Y_diamond, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
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
end

function scroll_callback(slider_handle, target_axes, window_size)
    start_y = get(slider_handle, 'Max') - get(slider_handle, 'Value') + 1;
    %ylim(target_axes, [start_y, start_y + window_size]);
    ylim(target_axes, [start_y, start_y + window_size+1]);
end