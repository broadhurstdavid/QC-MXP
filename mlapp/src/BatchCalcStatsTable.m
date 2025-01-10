function [Stats] = BatchCalcStatsTable(Data,Feature,batch,baseConfig)

if batch ~= -1
    Data = Data(Data.Batch==batch,:);   
end

X = Data{:,Feature.UID};
isQC = logical(Data.QC);
isSample = logical(Data.Sample);
isBlank = logical(Data.Blank);
isReference = logical(Data.Reference);

if baseConfig.RemoveZeros
    X(X == 0) = NaN;
end
            
if baseConfig.LogTransformedCorrection
    X(X == 0) = NaN;
    X = log10(X);
end

for i = 1:width(X)
    [S(i).qcRSD,S(i).qcRSDlower95CI,S(i).qcRSDupper95CI,S(i).sampleRSD,S(i).sampleRSDlower95CI,S(i).sampleRSDupper95CI,S(i).refRSD,S(i).refRSDlower95CI,S(i).refRSDupper95CI,S(i).dRatio,S(i).blankRatio] = calcStats(X(:,i),isQC,isSample,isBlank,isReference,Logged=baseConfig.LogTransformedCorrection,BlankRatioMethod=baseConfig.BlankRatioMethod,RelativeLOQ=baseConfig.RelativeLOQ);
end

Stats = struct2table(S);
%Stats = movevars(Stats,'sampleMissing','Before',1);
%Stats = movevars(Stats,'qcMissing','Before',1);

end