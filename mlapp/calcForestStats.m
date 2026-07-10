function ForestStatsTable = calcForestStats(Features,BeforeDataTable,AfterDataTable,type,alpha,islog)

includeB = logical(BeforeDataTable.(type));
includeA = logical(AfterDataTable.(type));
if ~isequal(includeB,includeA)
    ME = MException('ForestPlot:UnexpectedDataMismatch',"Inclusion vector mismatch between Before and After tables");
    throw(ME);
end

n = height(Features);
RES = zeros(n,5);
for i = 1:n    
    before = BeforeDataTable{includeB,Features.UID(i)};
    after = AfterDataTable{includeA,Features.UID(i)};
    [meanDeltaCV,upperbound,lowerbound,cvB,cvA] = bootstrapDeltaCVconfidenceInterval(before,after,alpha,islog);
    RES(i,1) = meanDeltaCV*100;
    RES(i,2) = lowerbound*100;
    RES(i,3) = upperbound*100;
    RES(i,4) = cvB*100;
    RES(i,5) = cvA*100;
end

pooled_estimate = mean(RES(:,1));
sd_effects = std(RES(:,1)); 
pooled_SE = sd_effects / sqrt(n);

% Calculate Confidence Interval for the diamond (using t-distribution)

t_crit = tinv(1 - alpha/2, n - 1);
diamond_lower = pooled_estimate - (t_crit * pooled_SE);
diamond_upper = pooled_estimate + (t_crit * pooled_SE);


ForestStatsTable = Features(:,{'UID','Name'});

Table = array2table(RES,'VariableNames',{'meanDeltaCV','lowerCI','upperCI','cvB','cvA'});  

ForestStatsTable = [ForestStatsTable,Table];

oneRowTable = {{"PE"},{"PooledEffect"},pooled_estimate,diamond_lower,diamond_upper,NaN,NaN};

ForestStatsTable = [oneRowTable; ForestStatsTable];


% % --- 3. Set up the Plot ---
% figure('Position', [100, 100, 600, 400]);
% hold on;
% 
% % Line of no effect (usually 0 for differences, 1 for ratios)
% line_of_no_effect = 1; 
% plot([line_of_no_effect, line_of_no_effect], [0, n_studies + 2], 'k--', 'LineWidth', 1.5);
% 
% % --- 4. Plot Individual Study CIs and Effects ---
% for i = 1:n_studies
%     % Plot confidence interval lines
%     plot([lower_CIs(i), upper_CIs(i)], [i, i], 'b-', 'LineWidth', 1.5);
%     % Plot point estimates
%     plot(effect_sizes(i), i, 'bs', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
% end
% 
% % --- 5. Plot the Pooled Effect Diamond ---
% % Diamond coordinates: [Left tip, Center, Right tip, Center, Bottom tip]
% X_diamond = [diamond_lower, pooled_estimate, diamond_upper, pooled_estimate, diamond_lower];
% Y_diamond = [n_studies+0.5, n_studies+1, n_studies+0.5, n_studies, n_studies+0.5];
% 
% % Draw the diamond
% fill(X_diamond, Y_diamond, 'k', 'FaceAlpha', 0.5, 'EdgeColor', 'k');
% 
% % --- 6. Plot formatting ---
% ylim([0, n_studies + 2]);
% xlabel('Effect Size');
% yticks(1:n_studies);
% yticklabels({'Study 1', 'Study 2', 'Study 3', 'Study 4', 'Study 5'});
% title('Unweighted Forest Plot');
% set(gca, 'YDir', 'reverse'); % Invert Y-axis so Study 1 is at the top
% grid on;



end