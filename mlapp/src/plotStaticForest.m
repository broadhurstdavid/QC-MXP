function plotStaticForest(ForestTable)

sigCol = [0.85,0.1,0.1];
n_studies = height(ForestTable);

fig = uifigure('Position', [700, 100, 650, 900]);
fig.Scrollable = 'on';

plotPanel = uipanel(fig, 'Position', [10, 10, 620, 2000], 'BorderType', 'none');

ax1 = uiaxes(plotPanel, 'Position', [10, 10, 600, 1980]);
disableDefaultInteractivity(ax1);


% Line of no effect (usually 0 for differences, 1 for ratios)
line_of_no_effect = 0; 
plot(ax1,[line_of_no_effect, line_of_no_effect], [0, n_studies+2], 'k--', 'LineWidth', 1.5);
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

ylinedata = [2:n_studies+1;2:n_studies+1];
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
s = scatter(ax1,ForestTable.meanDeltaCV, 2:n_studies+1, ms, 's','MarkerFaceColor','flat','AlphaDataMapping','none','CData',mfc);
alpha(s,mfa);

% Plot formatting ---
%ylim(ax1, [1, 1 + window_size]);
%ylim(ax,[0, n_studies+2]);
xlim(ax1,[xlim_lower, xlim_upper]);
xlabel(ax1,['Delta %RSD (After ',char(8211),' Before)']);
ylabel(ax1,'');
yticks(ax1,2:n_studies+1);
yticklabels(ax1,ForestTable.ShortName(1:end));
ax1.YAxis.FontSize = 8;
ax1.TickLength = [0.005, 0.025]; 
set(ax1, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
grid(ax1,'on');
box(ax1,'on');

end