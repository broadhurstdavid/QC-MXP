function [RES] = qcrscPCA(Data,Feature,options)

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

        warning off

        isQC = logical(Data.QC);
        isSample = logical(Data.Sample);
        Z0 = ZZ(isSample,:);
        [coeff,~,latent,~,explained] = pca(Z0);
        Score = ZZ*coeff;
        warning on  


        qcV = var(Score(isQC,:),"omitnan")';  
        DRatio = 100*sqrt(qcV./latent); 
        
        cumVar = cumsum(explained);
        cumMPQ = 100*sqrt(cumsum(qcV)./cumsum(latent));
        found = find(cumVar > 95,1,'first')-1;
        
        MPQ = 100*sqrt(sum(qcV)./sum(latent));

        if found == 0
            MPQ95 = MPQ;
        else
            MPQ95 = cumMPQ(found);
        end
        RES.X = ZZ;
        RES.Score = Score;
        RES.coeff = coeff;
        RES.latent = latent;
        RES.qcV = qcV;
        RES.explained = explained;
        RES.DRatio = DRatio;
        RES.cumVar = cumVar;
        RES.cumMPQ = cumMPQ;
        RES.MPQ = MPQ;
        RES.MPQ95 = MPQ95;
        RES.Options = options;
end