function [ZZ] = PCApreprocessing(Data,Feature,options)

    arguments
       Data {mustBeA(Data,'table')}
       Feature {mustBeA(Feature,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcolumn','KNNrow','blank20'})} = 'KNNcolumn'
       options.LogTransform {mustBeNumericOrLogical} = true
       options.ScaleMethod {mustBeMember(options.ScaleMethod,{'MeanCenter','Autoscale','Paretoscale'})} = 'Autoscale'
       options.k {mustBeInteger,mustBePositive} = 3
       options.batchScale {mustBeNumericOrLogical} = false
    end
    
    k = options.k;
    batchnum = Data.Batch;
            
    cleanPeaks = logical(Feature.cleanPeaks);
    FeatureClean = Feature(cleanPeaks,:);            
    ZZ = Data{:,FeatureClean.UID};
    isQC = logical(Data.QC);
    isSample = logical(Data.Sample);
    isBlank = logical(Data.Blank);
    isREF = logical(Data.Reference);
    
    if options.RemoveZeros
        ZZ(ZZ == 0) = NaN;
    end 
    
    % replace missing Blanks with mean 
    ZZblank = ZZ(isBlank,:);
    meanBlank = mean(ZZblank,1,"omitmissing");
    meanBlankX = repmat(meanBlank,height(ZZblank),1);
    temp = isnan(ZZblank);
    ZZblank(temp) = meanBlankX(temp);
    
    % or 10% of lowest value
    
    min10Val = min(ZZ,[],1)*0.1;
    msampleX = repmat(min10Val,height(ZZblank),1);
    temp = isnan(ZZblank);
    ZZblank(temp) = msampleX(temp);
    ZZ(isBlank,:) = ZZblank;
    
    switch options.ImputationType
        %%%%%%%%%%%%%%%% 'KNNcolumn' %%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'KNNcolumn'
            if options.LogTransform
                ZZ(ZZ == 0) = NaN;
                ZZ = log10(ZZ);
            end
            switch options.ScaleMethod
                case 'Autoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                case 'Paretoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                otherwise
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'center');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent] = normalize(Z0,1,'center');
                        ZZ = (ZZ-cent);
                    end
            end
                       
            % replace missing QCs with mean
            ZZqc = ZZ(isQC,:);                        
            mqc = mean(ZZqc,1,'omitnan');
            mqcX = repmat(mqc,height(ZZqc),1);
            temp = isnan(ZZqc);
            ZZqc(temp) = mqcX(temp);
            ZZ(isQC,:) = ZZqc;     

            % replace missing REFs with mean
            ZZref = ZZ(isREF,:);                        
            mref = mean(ZZref,1,'omitnan');
            mrefX = repmat(mref,height(ZZref),1);
            temp = isnan(ZZref);
            ZZref(temp) = mrefX(temp);
            ZZ(isREF,:) = ZZref;     
     
            % replace every other missing with KNN
            try
                ZZ = knnimpute(ZZ,k);
            catch
                try
                    ZZ=incrementalKNNimpute(ZZ,k);
                catch exception
                    throw(exception)
                end
            end
    
        %%%%%%%%%%%%%%%% 'KNNrow' %%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'KNNrow'
            if options.LogTransform
                ZZ(ZZ == 0) = NaN;
                ZZ = log10(ZZ);
            end
            switch options.ScaleMethod
                case 'Autoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                case 'Paretoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                otherwise
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'center');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent] = normalize(Z0,1,'center');
                        ZZ = (ZZ-cent);
                    end
            end        
            % replace missing QCs with KNN QC values or mean
            ZZqc = ZZ(isQC,:);
            try
                ZZqc = knnimpute(ZZqc',k)';
            catch
                mqc = mean(ZZqc,1,'omitnan');
                mqcX = repmat(mqc,height(ZZqc),1);
                temp = isnan(ZZqc);
                ZZqc(temp) = mqcX(temp);
            end
            ZZ(isQC,:) = ZZqc;


           % replace missing REFs with KNN QC values or mean
            ZZref = ZZ(isREF,:);  
            try
                ZZref = knnimpute(ZZref',k)';
            catch
                mref = mean(ZZref,1,'omitnan');
                mrefX = repmat(mref,height(ZZref),1);
                temp = isnan(ZZref);
                ZZref(temp) = mrefX(temp);
                ZZ(isREF,:) = ZZref;
            end
            ZZ(isREF,:) = ZZref;
    
            % replace every other missing with KNN
            try
                ZZ = knnimpute(ZZ',k)';
            catch
                try
                    ZZ=incrementalKNNimpute(ZZ',k)';
                catch exception
                    throw(exception)
                end
            end
        %%%%%%%%%%%%%%%% 'blank/20%' %%%%%%%%%%%%%%%%%%%%%%%%%%
        otherwise
            % replace missing QCs with mean QC value
            ZZqc = ZZ(isQC,:);
            mqc = mean(ZZqc,1,'omitnan');
            mqcX = repmat(mqc,height(ZZqc),1);
            temp = isnan(ZZqc);
            ZZqc(temp) = mqcX(temp);
            ZZ(isQC,:) = ZZqc;
            % replace missing REFs with mean
            ZZref = ZZ(isREF,:);                        
            mref = mean(ZZref,1,'omitnan');
            mrefX = repmat(mref,height(ZZref),1);
            temp = isnan(ZZref);
            ZZref(temp) = mrefX(temp);
            ZZ(isREF,:) = ZZref;  
            % replace missing nonQCs with blank value
            temp = isnan(ZZ);
            minValX = repmat(min10Val,height(ZZ),1);
            ZZ(temp) = minValX(temp);
            %
            if options.LogTransform
                ZZ(ZZ == 0) = NaN;
                ZZ = log10(ZZ);
            end
            switch options.ScaleMethod
                case 'Autoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                case 'Paretoscale'
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                otherwise
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'center');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent] = normalize(Z0,1,'center');
                        ZZ = (ZZ-cent);
                    end
            end                           
    end
end