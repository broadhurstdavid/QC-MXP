function [ZZ] = PCApreprocessing(Data,Peak,options)

    arguments
       Data {mustBeA(Data,'table')}
       Peak {mustBeA(Peak,'table')}
       options.RemoveZeros {mustBeNumericOrLogical} = true
       options.ImputationType {mustBeMember(options.ImputationType,{'KNNcol','KNNrow','blank20'})} = 'KNNcol'
       options.Fold {mustBeNumericOrLogical} = true
       options.LogTransform {mustBeNumericOrLogical} = true    
       options.Autoscale {mustBeNumericOrLogical} = true
       options.Paretoscale {mustBeNumericOrLogical} = false
       options.k {mustBeInteger,mustBePositive} = 3
    end
    
    k = options.k;

        if options.Autoscale && options.Paretoscale
                ME = MException('PCApreprocessing:invalid option','Autoscale & Paretoscale cannot both be True');
                throw(ME)
        end

        if options.Fold && options.LogTransform
                ME = MException('PCApreprocessing:invalid option','Fold & LogTransform cannot both be True');
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

        % replace missing Blanks with 10% of lowest value
        ZZblank = ZZ(isBlank,:);
        min10Val = min(ZZ,[],1,'omitnan')*0.1;
        msampleX = repmat(min10Val,height(ZZblank),1);
        temp = isnan(ZZblank);
        ZZblank(temp) = msampleX(temp);
        ZZ(isBlank,:) = ZZblank;
        
        switch options.ImputationType
            %%%%%%%%%%%%%%%% 'KNNcol' %%%%%%%%%%%%%%%%%%%%%%%%%%
            case 'KNNcol'
                if options.Fold
                    ZZqc = ZZ(isQC,:);
                    meanQC = mean(ZZqc,"omitmissing");
                    ZZ(ZZ == 0) = NaN;
                    ZZ = ZZ./meanQC;
                    ZZ = log2(ZZ);
                    if options.Autoscale 
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./scle;
                    elseif options.Paretoscale
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./sqrt(scle);
                    end
                elseif options.LogTransform
                    ZZ(ZZ == 0) = NaN;
                    ZZ = log10(ZZ);
                    if options.Autoscale 
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    elseif options.Paretoscale
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end
                end           
                % replace missing QCs with KNN QC values or mean
                ZZqc = ZZ(isQC,:);
                try
                    ZZqc = knnimpute(ZZqc,k);
                catch                
                    mqc = mean(ZZqc,'omitnan');
                    mqcX = repmat(mqc,height(ZZqc),1);
                    temp = isnan(ZZqc);
                    ZZqc(temp) = mqcX(temp);
                    ZZ(isQC,:) = ZZqc;               
                end
                ZZ(isQC,:) = ZZqc;

                % replace missing Blanks with KNN QC values or mean

                ZZblank = ZZ(isBlank,:);
                try
                    ZZblank = knnimpute(ZZblank,k);
                catch                
                    mblank = mean(ZZblank,'omitnan');
                    if isnan(mblank)
                        mblank = min10Val;
                    end
                    mblankX = repmat(mblank,height(ZZblank),1);
                    temp = isnan(ZZblank);
                    ZZblank(temp) = mblankX(temp);
                    ZZ(isblank,:) = ZZblank;               
                end
                ZZ(isBlank,:) = ZZblank;

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
                if options.Fold
                    ZZqc = ZZ(isQC,:);
                    meanQC = mean(ZZqc,"omitmissing");
                    ZZ(ZZ == 0) = NaN;
                    ZZ = ZZ./meanQC;
                    ZZ = log2(ZZ);
                    if options.Autoscale 
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./scle;
                    elseif options.Paretoscale
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./sqrt(scle);
                    end
                elseif options.LogTransform
                    ZZ(ZZ == 0) = NaN;
                    ZZ = log10(ZZ);
                    if options.Autoscale 
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    elseif options.Paretoscale
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
                    mqc = mean(ZZqc,'omitnan');
                    mqcX = repmat(mqc,height(ZZqc),1);
                    temp = isnan(ZZqc);
                    ZZqc(temp) = mqcX(temp);
                    ZZ(isQC,:) = ZZqc;
                end
                ZZ(isQC,:) = ZZqc;

                % replace missing Blanks with KNN blank values or mean

                ZZblank = ZZ(isBlank,:);
                try
                    ZZblank = knnimpute(ZZblank',k)';
                catch                
                    mblank = mean(ZZblank,'omitnan');
                    if isnan(mblank)
                        mblank = min10Val;
                    end
                    mblankX = repmat(mblank,height(ZZblank),1);
                    temp = isnan(ZZblank);
                    ZZblank(temp) = mblankX(temp);
                    ZZ(isblank,:) = ZZblank;               
                end
                ZZ(isBlank,:) = ZZblank;

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
                mqc = mean(ZZqc,'omitnan');
                mqcX = repmat(mqc,height(ZZqc),1);
                temp = isnan(ZZqc);
                ZZqc(temp) = mqcX(temp);
                ZZ(isQC,:) = ZZqc;
                % replace missing nonQCs with blank value
                temp = isnan(ZZ);
                minValX = repmat(min10Val,height(ZZ),1);
                ZZ(temp) = minValX(temp);
                %
                if options.Fold
                    ZZqc = ZZ(isQC,:);
                    meanQC = mean(ZZqc,"omitmissing");
                    ZZ(ZZ == 0) = NaN;
                    ZZ = ZZ./meanQC;
                    ZZ = log2(ZZ);
                    if options.Autoscale
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./scle;
                    elseif options.Paretoscale
                        Z0 = ZZ(isSample,:);
                        [~,~,scle] = normalize(Z0,1,'zscore');
                        ZZ = ZZ./sqrt(scle);
                    end 
                elseif options.LogTransform
                    ZZ(ZZ == 0) = NaN;
                    ZZ = log10(ZZ);
                    if options.Autoscale
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./scle;
                    elseif options.Paretoscale
                        Z0 = ZZ(isSample,:);
                        [~,cent,scle] = normalize(Z0,1,'zscore');
                        ZZ = (ZZ-cent)./sqrt(scle);
                    end   
                end                         
        end
end