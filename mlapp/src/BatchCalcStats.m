function [Stats] = BatchCalcStats(y,batch,isQC,isBlank,isReference,options)

arguments
    y
    batch
    isQC {mustBeNumericOrLogical}
    isBlank {mustBeNumericOrLogical}
    isReference {mustBeNumericOrLogical}
    options.Logged {mustBeNumericOrLogical} = true
    options.Parametric {mustBeNumericOrLogical} = true
    options.BlankRatioMethod {mustBeMember(options.BlankRatioMethod,{'QC','Median','Percentile'})} = 'Percentile'
end

batchNumTotal = unique(batch);

for i = 1:length(batchNumTotal)
    yi = y(batch == i);
    isQCi = isQC(batch == i);
    isBlanki = isBlank(batch == i);
    isReferencei = isReference(batch == i);
    S(i).This = ['Batch ',num2str(i)];
    [S(i).rsdQC,S(i).dRatio,S(i).rsdREF,S(i).blankRatio] = calcStats(yi,isQCi,isBlanki,isReferencei,Logged=options.Logged,Parametric=options.Parametric,BlankRatioMethod=options.BlankRatioMethod);
end

warning('off')
Stats = struct2table(S);
Stats.Properties.VariableNames = {'Batch','qcRSC','dRatio','refRSD','blankRatio'};
Stats = rows2vars(Stats,'VariableNamesSource',1);
Stats.Properties.VariableNames(1) = {' '};
warning('on')

end