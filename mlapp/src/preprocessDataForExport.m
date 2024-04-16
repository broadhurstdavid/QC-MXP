function [DataX] = preprocessDataForExport(Data,Peak,options)

    arguments
       Data {mustBeA(Data,'table')}
       Peak {mustBeA(Peak,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcol','KNNrow','blank20'})} = 'KNNcol'
       options.Fold {mustBeNumericOrLogical} = true
       options.LogTransform {mustBeNumericOrLogical} = true    
       options.Autoscale {mustBeNumericOrLogical} = true
       options.Paretoscale {mustBeNumericOrLogical} = false
    end        
       [ZZ] = PCApreprocessing(Data,Peak,RemoveZeros=options.RemoveZeros,ImputationType=options.ImputationType,Fold=options.Fold,LogTransform=options.LogTransform,Autoscale=options.Autoscale,Paretoscale=options.Paretoscale);
       DataX = Data;
       DataX{:,Peak.UID} = ZZ;

end