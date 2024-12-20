function [DataX] = preprocessDataForExport(Data,Feature,options)

    arguments
       Data {mustBeA(Data,'table')}
       Feature {mustBeA(Feature,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcol','KNNrow','blank20'})} = 'KNNcol'
       options.LogTransform {mustBeNumericOrLogical} = true    
       options.Autoscale {mustBeNumericOrLogical} = true
       options.Paretoscale {mustBeNumericOrLogical} = false
       options.batchScale {mustBeNumericOrLogical} = false
       options.k {mustBeInteger,mustBePositive} = 3
    end        
       [ZZ] = PCApreprocessing(Data,Feature,RemoveZeros=options.RemoveZeros,ImputationType=options.ImputationType,LogTransform=options.LogTransform,Autoscale=options.Autoscale,Paretoscale=options.Paretoscale,batchScale=options.batchScale,k=options.k);
       DataX = Data;
       DataX{:,Feature.UID} = ZZ;

end