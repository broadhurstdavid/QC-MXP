function [DataX] = preprocessDataForExport(Data,Peak,options)

    arguments
       Data {mustBeA(Data,'table')}
       Peak {mustBeA(Peak,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcol','KNNrow','blank20'})} = 'KNNcol'
       options.LogTransform {mustBeNumericOrLogical} = true    
       options.Autoscale {mustBeNumericOrLogical} = true
       options.Paretoscale {mustBeNumericOrLogical} = false
       options.batchScale {mustBeNumericOrLogical} = false
       options.k {mustBeInteger,mustBePositive} = 3
    end        
       [ZZ] = PCApreprocessing(Data,Peak,RemoveZeros=options.RemoveZeros,ImputationType=options.ImputationType,LogTransform=options.LogTransform,Autoscale=options.Autoscale,Paretoscale=options.Paretoscale,batchScale=options.batchScale,k=options.k);
       DataX = Data;
       DataX{:,Peak.UID} = ZZ;

end