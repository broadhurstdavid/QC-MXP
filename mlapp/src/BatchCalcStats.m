function [Stats] = BatchCalcStats(y,batch,isQC,isSample,isBlank,isReference,options)

arguments
    y
    batch
    isQC {mustBeNumericOrLogical}
    isSample {mustBeNumericOrLogical}
    isBlank {mustBeNumericOrLogical}
    isReference {mustBeNumericOrLogical}
    options.Logged {mustBeNumericOrLogical} = true
    options.BlankRatioMethod {mustBeMember(options.BlankRatioMethod,{'QC','Median','Percentile'})} = 'Percentile'
end

batchNumTotal = unique(batch);

for i = 1:length(batchNumTotal)
    yi = y(batch == i);
    isQCi = isQC(batch == i);
    isSamplei = isSample(batch == i);
    isBlanki = isBlank(batch == i);
    isReferencei = isReference(batch == i);
    %[S(i).rsdQC,S(i).rsdQClower,S(i).rsdQCupper,S(i).rsdSAMPLE,S(i).rsdSAMPLElower,S(i).rsdSAMPLEupper,S(i).rsdREF,S(i).rsdREFlower,S(i).rsdREFupper,S(i).dRatio,S(i).blankRatio] = calcStats(yi,isQCi,isSamplei,isBlanki,isReferencei,Logged=options.Logged,BlankRatioMethod=options.BlankRatioMethod);
    Si = calcStats(yi,isQCi,isSamplei,isBlanki,isReferencei,Logged=options.Logged,BlankRatioMethod=options.BlankRatioMethod);   
    Si.Batch = ['Batch ',num2str(i)];
    S(i) = Si;
end

warning('off')
Stats = struct2table(S);
Stats = movevars(Stats,'Batch','Before',1);
%Stats.Properties.VariableNames = {'Batch','qcRSD','qcRSClower95CI','qcRSCupper95CI','sampleRSD','sampleRSDlower95CI','sampleRSDupper95CI','refRSD','refRSDlower95CI','refRSDupper95CI','dRatio','blankRatio'};
Stats = rows2vars(Stats,'VariableNamesSource',1);
Stats.Properties.VariableNames(1) = {' '};
warning('on')

end