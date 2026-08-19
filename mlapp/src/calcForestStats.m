function ForestStatsTable = calcForestStats(Features,BeforeDataTable,AfterDataTable,type,alpha,islog,bootNum)

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
        try
            [meanDeltaCV,upperbound,lowerbound,cvB,cvA,sig] = bootstrapDeltaCVconfidenceInterval(before,after,alpha,islog,bootNum);
        catch
            meanDeltaCV = NaN;
            upperbound = NaN;
            lowerbound = NaN;
            cvB = NaN;
            cvA = NaN;
            sig = false;
        end
        RES(i,1) = meanDeltaCV*100;
        RES(i,2) = lowerbound*100;
        RES(i,3) = upperbound*100;
        RES(i,4) = cvB*100;
        RES(i,5) = cvA*100;
        RES(i,6) = sig;
    end


pooled_estimate = mean(RES(:,1));
sd_effects = std(RES(:,1)); 
pooled_SE = sd_effects / sqrt(n);

% Calculate Confidence Interval for the diamond (using t-distribution)

t_crit = tinv(1 - alpha/2, n - 1);
diamond_lower = pooled_estimate - (t_crit * pooled_SE);
diamond_upper = pooled_estimate + (t_crit * pooled_SE);

if diamond_lower > 0
    sig_p = true;
else
    sig_p = false;
end

if ~all(Features.cleanPeaks)
    keep = Features.cleanPeaks;
    pooled_estimateX = mean(RES(keep,1));
    sd_effectsX = std(RES(keep,1)); 
    nX = sum(keep);
    pooled_SEX = sd_effectsX / sqrt(nX);

    t_critX = tinv(1 - alpha/2, nX - 1);
    diamond_lowerX = pooled_estimateX - (t_critX * pooled_SEX);
    diamond_upperX = pooled_estimateX + (t_critX * pooled_SEX);

    if diamond_lowerX > 0
        sig_pX = true;
    else
        sig_pX = false;
    end
else
    pooled_estimateX = pooled_estimate;
    diamond_lowerX = diamond_lower;
    diamond_upperX = diamond_upper;  
    sig_pX = sig_p;
end


Table = array2table(RES,'VariableNames',{'meanDeltaCV','lowerCI','upperCI','cvB','cvA','sig'});  

ForestStatsTable = [Features,Table];

varNames = ForestStatsTable.Properties.VariableNames;
varTypes = ForestStatsTable.Properties.VariableTypes;
sz = [2, numel(varNames)];

SubTable = table('Size', sz,'VariableTypes', varTypes,'VariableNames', varNames);
t = ismember(varTypes,'cell');
SubTable(:,t) = repmat({'x'},2,sum(t));

SubTable.meanDeltaCV = [pooled_estimate;pooled_estimateX];
SubTable.lowerCI = [diamond_lower;diamond_lowerX];
SubTable.upperCI = [diamond_upper;diamond_upperX];
SubTable.sig = [sig_p;sig_pX];
SubTable.Name = {'Before';'After'};

ForestStatsTable = [SubTable; ForestStatsTable];

ForestStatsTable.sig = logical(ForestStatsTable.sig);

end