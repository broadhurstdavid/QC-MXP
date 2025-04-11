function [DataX] = preprocessDataForExport(Data,Feature,options)

    arguments
       Data {mustBeA(Data,'table')}
       Feature {mustBeA(Feature,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcolumn','KNNrow','blank20'})} = 'KNNcolumn'
       options.LogTransform {mustBeNumericOrLogical} = true 
       options.ScaleMethod {mustBeMember(options.ScaleMethod,{'MeanCenter','Autoscale','Paretoscale'})} = 'Autoscale'
       options.batchScale {mustBeNumericOrLogical} = false
       options.k {mustBeInteger,mustBePositive} = 3 
    end        
       [ZZ] = PCApreprocessing(Data,Feature,RemoveZeros=options.RemoveZeros,ImputationType=options.ImputationType,LogTransform=options.LogTransform,ScaleMethod=options.ScaleMethod,k=options.k,batchScale=options.batchScale);
       DataX = Data;
       DataX{:,Feature.UID} = ZZ;

end