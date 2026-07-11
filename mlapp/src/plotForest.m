function  plotForest(ForestTable)

% --- 3. Set up the Plot ---
figure('Position', [100, 100, 400, 800]);
hold on;

n_studies = height(ForestTable);

% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
semilogx([line_of_no_effect, line_of_no_effect], [0, n_studies + 2], 'k--', 'LineWidth', 1.5);

% --- 4. Plot Individual Study CIs and Effects ---
for i = 2:n_studies
    % Plot confidence interval lines
    semilogx([ForestTable.lowerCI(i), ForestTable.upperCI(i)], [i+1, i+1], 'b-', 'LineWidth', 1.5);
    % Plot point estimates
    semilogx(ForestTable.meanDeltaCV(i), i+1, 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
end

% --- 6. Plot formatting ---
ylim([0, n_studies+2]);
xlim([-10, 80]);
xlabel('Delta RSD (After-Before)');
yticks(2:n_studies);
yticklabels(ForestTable.Name(2:end));
title('Unweighted Forest Plot');
set(gca, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid on;
box on;

% --- 5. Plot the Pooled Effect Diamond ---
% Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
X_diamond = [ForestTable.lowerCI(1), ForestTable.meanDeltaCV(1), ForestTable.upperCI(1), ForestTable.meanDeltaCV(1), ForestTable.lowerCI(1)];
Y_diamond = [1, 1.75, 1, 0.25, 1];
%Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];

% Draw the diamond
fill(X_diamond, Y_diamond, 'r', 'FaceAlpha', 0.5, 'EdgeColor', 'k');

end