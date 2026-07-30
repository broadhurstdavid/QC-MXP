function  plotForest(ForestTable)


PoolTable = ForestTable(1,:);
ForestTable = ForestTable(2:end,:);

fig = figure('Name', 'Scrollable Plot', 'Position', [100, 100, 600, 400]);
ax = axes('Parent', fig);

window_size = 20; 

% --- 3. Set up the Plot ---
%figure('Position', [100, 100, 400, 800]);


n_studies = height(ForestTable);

% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax,[line_of_no_effect, line_of_no_effect], [0, n_studies + 2], 'k--', 'LineWidth', 1.5);
hold(ax,"on");

% --- 4. Plot Individual Study CIs and Effects ---
for i = 1:n_studies
    % Plot confidence interval lines
    plot(ax,[ForestTable.lowerCI(i), ForestTable.upperCI(i)], [i+1, i+1], 'b-', 'LineWidth', 1.5);
    % Plot point estimates
    plot(ax,ForestTable.meanDeltaCV(i), i+1, 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
end

% --- 6. Plot formatting ---
ylim(ax, [0, 0 + window_size]);
%ylim(ax,[0, n_studies+2]);
xlim(ax,[-10, 80]);
xlabel(ax,'Delta RSD (After-Before)');
yticks(ax,2:n_studies+1);
yticklabels(ax,ForestTable.Name(1:end));
title(ax,'Unweighted Forest Plot');
set(ax, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid(ax,'on');
box(ax,'on');

% --- 5. Plot the Pooled Effect Diamond ---
% Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
X_diamond = [ForestTable.lowerCI(1), ForestTable.meanDeltaCV(1), ForestTable.upperCI(1), ForestTable.meanDeltaCV(1), ForestTable.lowerCI(1)];
Y_diamond = [1, 1.5, 1, 0.5, 1];
%Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];

% Draw the diamond
fill(ax,X_diamond, Y_diamond, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');

end