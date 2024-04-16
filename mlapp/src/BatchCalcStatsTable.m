function [Stats] = BatchCalcStatsTable(Data,Peak,batch,baseConfig)

if batch ~= -1
    Data = Data(Data.Batch==batch,:);   
end

X = Data{:,Peak.UID};
isQC = logical(Data.QC);
isBlank = logical(Data.Blank);
isReference = logical(Data.Reference);

if baseConfig.RemoveZeros
    X(X == 0) = NaN;
end
            
if baseConfig.LogTransform
    X(X == 0) = NaN;
    X = log10(X);
end

for i = 1:width(X)
    [S(i).qcRSD,S(i).dRatio,S(i).refRSD,S(i).blankRatio,S(i).sampleRSD] = calcStats(X(:,i),isQC,isBlank,isReference,Logged=baseConfig.LogTransform,Parametric=baseConfig.StatsParametric,BlankRatioMethod=baseConfig.BlankRatioMethod);
end

Stats = struct2table(S);

end