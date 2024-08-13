function [ZZ] = PCApreprocessing(Data,Peak,options)

    arguments
       Data {mustBeA(Data,'table')}
       Peak {mustBeA(Peak,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcol','KNNrow','blank20'})} = 'KNNcol'
       options.LogTransform {mustBeNumericOrLogical} = true    
       options.Autoscale {mustBeNumericOrLogical} = true
       options.Paretoscale {mustBeNumericOrLogical} = false
       options.k {mustBeInteger,mustBePositive} = 3
       options.batchScale {mustBeNumericOrLogical} = false
    end
    
    k = options.k;
    batchnum = Data.Batch;

        if options.Autoscale && options.Paretoscale
                ME = MException('PCApreprocessing:invalid option','Autoscale & Paretoscale cannot both be True');
                throw(ME)
        end
            
        cleanPeaks = logical(Peak.cleanPeaks);
        PeakClean = Peak(cleanPeaks,:);            
        ZZ = Data{:,PeakClean.UID};
        isQC = logical(Data.QC);
        isSample = logical(Data.Sample);
        isBlank = logical(Data.Blank);

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
            %%%%%%%%%%%%%%%% 'KNNcol' %%%%%%%%%%%%%%%%%%%%%%%%%%
            case 'KNNcol'
                if options.LogTransform
                    ZZ(ZZ == 0) = NaN;
                    ZZ = log10(ZZ);
                end
                if options.Autoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                elseif options.Paretoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                end
                           
                % replace missing QCs with mean
                ZZqc = ZZ(isQC,:);                        
                mqc = mean(ZZqc,1,'omitnan');
                mqcX = repmat(mqc,height(ZZqc),1);
                temp = isnan(ZZqc);
                ZZqc(temp) = mqcX(temp);
                ZZ(isQC,:) = ZZqc;               
                
                

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
                if options.Autoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                elseif options.Paretoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
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
                    ZZ(isQC,:) = ZZqc;
                end
                ZZ(isQC,:) = ZZqc;

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
                % replace missing nonQCs with blank value
                temp = isnan(ZZ);
                minValX = repmat(min10Val,height(ZZ),1);
                ZZ(temp) = minValX(temp);
                %
                if options.LogTransform
                    ZZ(ZZ == 0) = NaN;
                    ZZ = log10(ZZ);
                end
                if options.Autoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'autoscale');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    end
                elseif options.Paretoscale
                    if options.batchScale
                        ZZ = batchScale(ZZ,isSample,batchnum,'pareto');
                    else
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                end                           
        end
end