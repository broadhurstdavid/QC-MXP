function ForestStatsTable = calcForestStats(Features,BeforeDataTable,AfterDataTable,type,alpha,islog)

includeB = logical(BeforeDataTable.(type));
includeA = logical(AfterDataTable.(type));
if ~isequal(includeB,includeA)
    ME = MException('ForestPlot:UnexpectedDataMismatch',"Inclusion vector mismatch between Before and After tables");
    throw(ME);
end

n = height(Features);
RES = zeros(n,6);
for i = 1:n    
    before = BeforeDataTable{includeB,Features.UID(i)};
    after = AfterDataTable{includeA,Features.UID(i)};
    [meanDeltaCV,upperbound,lowerbound,cvB,cvA,sig] = bootstrapDeltaCVconfidenceInterval(before,after,alpha,islog);
    RES(i,1) = meanDeltaCV*100;
    RES(i,2) = lowerbound*100;
    RES(i,3) = upperbound*100;
    RES(i,4) = cvB*100;
    RES(i,5) = cvA*100;
    RES(i,6) = sig;
end

keep = Features.cleanPeaks;
pooled_estimate = mean(RES(:,1));
sd_effects = std(RES(:,1)); 
pooled_SE = sd_effects / sqrt(n);


pooled_estimateX = mean(RES(keep,1));
sd_effectsX = std(RES(keep,1)); 
nX = sum(keep);
pooled_SEX = sd_effectsX / sqrt(nX);

% Calculate Confidence Interval for the diamond (using t-distribution)

t_crit = tinv(1 - alpha/2, n - 1);
diamond_lower = pooled_estimate - (t_crit * pooled_SE);
diamond_upper = pooled_estimate + (t_crit * pooled_SE);

t_critX = tinv(1 - alpha/2, nX - 1);
diamond_lowerX = pooled_estimateX - (t_critX * pooled_SEX);
diamond_upperX = pooled_estimateX + (t_critX * pooled_SEX);

if diamond_lower > 0
    sig_p = true;
else
    sig_p = false;
end

if diamond_lowerX > 0
    sig_pX = true;
else
    sig_pX = false;
end


ForestStatsTable = Features(:,{'UID','Name','cleanPeaks'});

Table = array2table(RES,'VariableNames',{'meanDeltaCV','lowerCI','upperCI','cvB','cvA','sig'});  

ForestStatsTable = [ForestStatsTable,Table];

oneRowTable = {{"PE"},{"PooledEffect"},false,pooled_estimate,diamond_lower,diamond_upper,NaN,NaN,sig_p};
twoRowTable = {{"PE"},{"PooledEffect"},false,pooled_estimateX,diamond_lowerX,diamond_upperX,NaN,NaN,sig_pX};

ForestStatsTable = [oneRowTable; twoRowTable; ForestStatsTable];

ForestStatsTable.sig = logical(ForestStatsTable.sig);

end