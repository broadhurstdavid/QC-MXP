 function [a1,a2,b,c,grps] = plotPCAXX(axishandle,Data,pcaRES,options)

    arguments
       axishandle {mustBeA(axishandle,'matlab.ui.control.UIAxes')}
       Data {mustBeA(Data,'table')}
       pcaRES {mustBeA(pcaRES,'struct')}
       options.xaxis {mustBeInteger,mustBeGreaterThan(options.xaxis,-1)} = 1
       options.yaxis {mustBeInteger,mustBePositive} = 2
       options.label {mustBeA(options.label,{'char','string'})} = 'SampleType'
       options.plotDataPoints {mustBeNumericOrLogical} = true
       options.plotCIA {mustBeNumericOrLogical} = true
       options.plotCIB {mustBeNumericOrLogical} = true
       options.IncludeQCs {mustBeNumericOrLogical} = false
       options.IncludeBlanks {mustBeNumericOrLogical} = false
       options.IncludeRefs {mustBeNumericOrLogical} = false
       options.cmap = lines
    end
    
    cla(axishandle,'reset');
    grey = [0.7,0.7,0.7];
    if ismac
        sz = 18;
    else
        sz = 18;
    end
    ecol = [0.9,0.9,0.9];
    cmapx = options.cmap;
    %      {'blue','red','orange','purple'};
    %cols = {[0,68,136]./255,[221, 65, 36]./255,[230, 137, 40]./255,[175, 29, 139]./255};
    cols = {[0,68,136]./255,[255, 0, 0]./255,[230, 137, 40]./255,[175, 29, 139]./255};
    labels = {'Sample','QC','Blank','Reference'};
    hash = containers.Map(labels,cols);

%     val = [false,true];
%     sym = {'o','^'}; 
%     hash2 = containers.Map(val,sym);

    isSampleType = strcmp(options.label,'SampleType');
    %isBatchQC = strcmp(options.label,'BatchQC');
    
    Score = pcaRES.Score;

    keep = true(height(Data),1);

    if ~options.IncludeQCs
        keep = keep & ~Data.QC;
    end

    if ~options.IncludeBlanks
        keep = keep & ~Data.Blank;
    end

    if ~options.IncludeRefs
        keep = keep & ~Data.Reference;
    end
    
    Data = Data(keep,:);
    Score = Score(keep,:);
   
    xaxis = options.xaxis;
    yaxis = options.yaxis;

    if xaxis == 0
        SS = [Data.Order,Score(:,yaxis)];
    else
        SS = [Score(:,xaxis),Score(:,yaxis)];
    end
    hold(axishandle,"on");
    
    switch options.label
        case 'BatchQC'
            Y = Data{:,'Batch'};
            Y = cellstr(num2str(Y));
        case 'SampleType'
            Y = Data{:,options.label};
        case 'Batch'
            Y = Data{:,options.label};
            Y = cellstr(num2str(Y));
        otherwise
            Y = Data{:,options.label};
            if isnumeric(Y)
                Y = cellstr(num2str(Y));
            end          
            Y(Data.QC) = {'QC'};
            Y(Data.Blank) = {'Blank'};
            Y(Data.Reference) = {'Reference'};
            Y = strrep(Y,'_',' ');
    end

    
    grps = unique(Y);

    if length(grps) > 25
        baseException = MException('QCMXP:TooManyGroups',"There are too many groups. MaxNum = 25");
        throw(baseException)
    end

    

    %try
        if options.plotDataPoints
            %count = 1;
            for i = 1:length(grps)
                temp = ismember(Y,grps(i));                
                if sum(temp) == 0, continue; end
                switch options.label
                    case 'SampleType'
                        b(i) = scatter(axishandle,SS(temp,1),SS(temp,2),sz,hash(grps{i}),'filled','MarkerFaceAlpha',0.7,'MarkerEdgeColor',ecol);
                        b(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(temp));
                        b(i).DataTipTemplate.DataTipRows(2) = []; 
                        b(i).UserData = {grps{i},''};
                        b(i).DisplayName = grps{i};   
                    case 'BatchQC'                   
                        tempQC = temp & Data.QC;
                         tempSample = temp & Data.Sample;
                        b(i) = scatter(axishandle,SS(tempQC,1),SS(tempQC,2),sz,cmapx(i,:),'^','filled','MarkerFaceAlpha',0.7,'MarkerEdgeColor',ecol);                        
                        b(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(tempQC));
                        b(i).DataTipTemplate.DataTipRows(2) = dataTipTextRow('Batch:',Data.Batch(tempQC));
                        d(i) = scatter(axishandle,SS(tempSample,1),SS(tempSample,2),sz,cmapx(i,:),'o','filled','MarkerFaceAlpha',0.2);%,'MarkerEdgeColor',ecol); 
                        d(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(tempSample));
                        d(i).DataTipTemplate.DataTipRows(2) = dataTipTextRow('Batch:',Data.Batch(tempSample));
                        b(i).UserData = {['QC-',grps{i}],''};                       
                        b(i).DisplayName = grps{i};
                        d(i).UserData = {['Sample-',grps{i}],''};
                        d(i).DisplayName = ['Sample-',grps{i}];
                    otherwise
                        if any(strcmp(grps(i),{'QC','Blank','Reference'}))
                            b(i) = scatter(axishandle,SS(temp,1),SS(temp,2),sz,hash(grps{i}),'filled','MarkerFaceAlpha',0.7,'MarkerEdgeColor',ecol);
                        else
                            b(i) = scatter(axishandle,SS(temp,1),SS(temp,2),sz,cmapx(i,:),'filled','MarkerFaceAlpha',0.7,'MarkerEdgeColor',ecol);
                        end
                        b(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(temp));
                        b(i).DataTipTemplate.DataTipRows(2) = dataTipTextRow(options.label,Y(temp));
                        b(i).UserData = {grps{i},''};
                        b(i).DisplayName = grps{i};   
                end
                        
            end
        end
        
        if options.plotCIA || options.plotCIB
            for i = 1:length(grps)
                temp = ismember(Y,grps(i));
                if sum(temp) == 0, continue; end
                if sum(temp) > 2             
                    switch options.label
                        case 'SampleType'
                            [xm,ym] = ci95_ellipse2018(SS(temp,:),'mean');
                            [xp,yp] = ci95_ellipse2018(SS(temp,:),'pop');
                            if options.plotCIA
                                a2(i) = plot(axishandle,xp,yp,'--','linewidth',1,'color',hash(grps{i}));                  
                                a2(i).UserData = {grps{i},'Sample'};
                                a2(i).DisplayName = grps{i};
                                a2label = repmat(grps(i),length(xp));
                                a2(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,a2label);
                                a2(i).DataTipTemplate.DataTipRows(2) = [];
                            end
                        case 'BatchQC'
                            if options.plotCIA
                                tempQC = temp & Data.QC;                        
                                [xp1,yp1] = ci95_ellipse2018(SS(tempQC,:),'pop');
                                a1(i) = plot(axishandle,xp1,yp1,':','linewidth',1,'color',cmapx(i,:));                  
                                a1(i).UserData = {grps{i},'QC'};
                                a1(i).DisplayName = grps{i};
                                a1label = repmat(grps(i),length(xp1));     
                                a1(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('Batch',a1label);
                                a1(i).DataTipTemplate.DataTipRows(2) = [];
                            end
                            if options.plotCIB 
                                tempSample = temp & Data.Sample;                    
                                [xp,yp] = ci95_ellipse2018(SS(tempSample,:),'pop');
                                a2(i) = plot(axishandle,xp,yp,'--','linewidth',1,'color',cmapx(i,:));                  
                                a2(i).UserData = {grps{i},'Sample'};
                                a2(i).DisplayName = grps{i};
                                a2label = repmat(grps(i),length(xp));
                                a2(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('Batch',a2label);
                                a2(i).DataTipTemplate.DataTipRows(2) = [];
                            end
                        otherwise
                            if any(strcmp(grps(i),{'QC','Blank','Reference'}))
                                if options.plotCIA
                                    a1(i) = plot(axishandle,xm,ym,':','linewidth',1,'color',hash(grps{i})); 
                                    a1label = repmat(grps(i),length(xm));     
                                    a1(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,a1label);
                                    a1(i).DataTipTemplate.DataTipRows(2) = [];                      
                                    a1(i).UserData = {grps{i},'CI mean'};
                                    a1(i).DisplayName = grps{i};
                                end
                                if options.plotCIB
                                    a2(i) = plot(axishandle,xp,yp,'--','linewidth',1,'color',hash(grps{i})); 
                                    a2(i).UserData = {grps{i},'CI pop'};
                                    a2(i).DisplayName = grps{i};
                                    a2label = repmat(grps(i),length(xp));
                                    a2(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,a2label);
                                    a2(i).DataTipTemplate.DataTipRows(2) = [];
                                end
                            else
                                tempSample = temp & Data.Sample;   
                                [xm,ym] = ci95_ellipse2018(SS(tempSample,:),'mean');
                                [xp,yp] = ci95_ellipse2018(SS(tempSample,:),'pop');
                                if options.plotCIA
                                    a1(i) = plot(axishandle,xm,ym,':','linewidth',1,'color',cmapx(i,:)); 
                                    a1label = repmat(grps(i),length(xm));     
                                    a1(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,a1label);
                                    a1(i).DataTipTemplate.DataTipRows(2) = [];                      
                                    a1(i).UserData = {grps{i},'CI mean'};
                                    a1(i).DisplayName = grps{i};
                                end
                                if options.plotCIB
                                    a2(i) = plot(axishandle,xp,yp,'--','linewidth',1,'color',cmapx(i,:));                                     
                                    a2(i).UserData = {grps{i},'CI pop'};
                                    a2(i).DisplayName = grps{i};
                                    a2label = repmat(grps(i),length(xp));
                                    a2(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,a2label);
                                    a2(i).DataTipTemplate.DataTipRows(2) = [];
                                end
                            end                          
                    end                   
                    
                end
                
                if strcmp(options.label,'BatchQC')
                    tempQC = temp & Data.QC;
                    m = mean(SS(tempQC,:),1);
                else
                    m = mean(SS(temp,:),1);
                end        
                x0=m(1);
                y0=m(2);
                
                switch options.label
                    case 'SampleType'
                        m = mean(SS(temp,:),1);
                        x0=m(1);
                        y0=m(2);
                        c(i) = plot(axishandle,x0,y0,'x','markersize',5,'color',hash(grps{i})); 
                    case 'BatchQC'
                        tempQC = temp & Data.QC;
                        m = mean(SS(tempQC,:),1);
                        x0=m(1);
                        y0=m(2);
                        c(i) = plot(axishandle,x0,y0,'x','markersize',5,'color',cmapx(i,:));
                    otherwise
                        if any(strcmp(grps(i),{'QC','Blank','Reference'}))
                            m = mean(SS(temp,:),1);
                            x0=m(1);
                            y0=m(2);
                            c(i) = plot(axishandle,x0,y0,'x','markersize',5,'color',hash(grps{i}));
                        else
                            tempSample = temp & Data.Sample; 
                            m = mean(SS(tempSample,:),1);
                            x0=m(1);
                            y0=m(2);
                            c(i) = plot(axishandle,x0,y0,'x','markersize',5,'color',cmapx(i,:)); 
                        end
                end
                    c(i).UserData = {grps{i},'mean'};
                    c(i).DisplayName = grps{i};
             end
        end
 

        if options.plotDataPoints
            legend(axishandle,b,string(grps));
        else
            legend(axishandle,c,string(grps));
        end
%     catch
%         baseException = MException('QCRSC:UnexpectedGroupLabel',"Something went wrong with the PCA labelling.");
%         throw(baseException)
%     end

    if isSampleType
        ylabel(axishandle,sprintf('PC%u (Explained Var(X) = %3.1f%%; dRatio = %.2f%%)',yaxis,pcaRES.explained(yaxis),pcaRES.DRatio(yaxis)),'FontSize',11);
        if xaxis == 0
            xlabel(axishandle,'Injection Order','FontSize',11);
        else             
            xlabel(axishandle,sprintf('PC%u (Explained Var(X) = %3.1f%%; dRatio = %.2f%%)',xaxis,pcaRES.explained(xaxis),pcaRES.DRatio(xaxis)),'FontSize',11);
        end
        switch pcaRES.Options.ScaleMethod
            case 'Autoscale'
                pcaTitle = {'Principal Component Analysis';sprintf('(sMPQ = %.2f%%; sMPQ_{95} = %.2f%%)',pcaRES.MPQ,pcaRES.MPQ95)};
            case 'MeanCenter'
                pcaTitle =  {'Principal Component Analysis';sprintf('(MPQ = %.2f%%; MPQ_{95} = %.2f%%)',pcaRES.MPQ,pcaRES.MPQ95)};
            otherwise
                pcaTitle =  {'Principal Component Analysis';sprintf('(pMPQ = %.2f%%; pMPQ_{95} = %.2f%%)',pcaRES.MPQ,pcaRES.MPQ95)};
        end
        axishandle.Title.String = pcaTitle;
    else
        ylabel(axishandle,sprintf('PC%u (Explained Var(X) = %3.1f%%)',yaxis,pcaRES.explained(yaxis)),'FontSize',11);
        if xaxis == 0
            xlabel(axishandle,'Injection Order','FontSize',11);
        else        
            xlabel(axishandle,sprintf('PC%u (Explained Var(X) = %3.1f%%)',xaxis,pcaRES.explained(xaxis)),'FontSize',11);
        end
        axishandle.Title.String = 'Principal Component Analysis';
    end
    
    axishandle.Title.FontSize = 12;
    axishandle.Title.Color = 'r';
    axishandle.Box = 'on'; 

end
            



