function [] = QCRSCplotdistribution2(axishandle,statsTable,BatchVector,options)

    arguments
       axishandle {mustBeA(axishandle,'matlab.ui.control.UIAxes')}
       statsTable {mustBeA(statsTable,'table')}
       BatchVector {mustBeInteger,mustBePositive}
       options.plotType {mustBeMember(options.plotType,{'histogram','pdf'})} = 'histogram'  
       options.split {mustBeMember(options.split ,{'all','batch'})} = 'all'
       options.smooth {mustBeNumeric,mustBeBetween(options.smooth,0,100)} = 20
       options.label {mustBeA(options.label,{'char','string'})} = 'qcRSD'
       options.cmap = lines;
       options.baseColor = [0.1333,0.5451,0.1333]
    end

ubatch = unique(BatchVector);
NumOfBatches = numel(ubatch);


cmap = mapRcolors('quoka');
smoothValue = (options.smooth+10)/30;

cla(axishandle,'reset');
%edges = [-1.125:0.25:3.125];
edges = [0:5:110];
center = edges(1:end-1) + diff(edges) / 2;



if strcmp(options.split,'all')
    cmap = [options.baseColor;cmap];
    ubatch = 1;
    NumOfBatches = 1;
    statsTable(:,[options.label,'B1']) = statsTable(:,options.label); 
end

statsTableClean = statsTable(statsTable.cleanPeaks,:);

if strcmp(options.plotType,'histogram')   
    for i = 1:NumOfBatches
        legendlabel{i} = ['B',num2str(ubatch(i))];
        colName = [options.label,'B',num2str(ubatch(i))];
        data = statsTable{:,colName};
        data(data>40) = 110;
        nAll(i,:) = histcounts(data,edges);
        data = statsTableClean{:,colName};
        data(data>40) = 110;
        nClean(i,:) = histcounts(data,edges);
        tt(i,:) = prctile(statsTableClean{:,colName},[25,50,75]);
    end
    plotAll = bar(axishandle,center,nAll','FaceColor','w','EdgeColor','k');
    hold(axishandle,"on");
    plotClean = bar(axishandle,center,nClean');
    for i = 1:numel(plotClean)
        plotClean(i).FaceColor = cmap(i,:);
    end

    maxval = max(max(nAll));

    tmp = string((round(10*edges))/10);
    temp = cellfun(@(x,y) strcat('(',x,'<x<',y,')'),tmp(1:end-1),tmp(2:end),'UniformOutput',false);   
    for i = 1:NumOfBatches
        if NumOfBatches ==1, blabel = repmat({'All'},length(center),1); else blabel = ones(length(center),1)*ubatch(i); end       
        plotAll(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,temp);
        plotAll(i).DataTipTemplate.DataTipRows(2).Label = '#Features';
        plotAll(i).DataTipTemplate.DataTipRows(3) = dataTipTextRow('Batch#',blabel);
        plotClean(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,temp);
        plotClean(i).DataTipTemplate.DataTipRows(2).Label = '#Features';
        plotClean(i).DataTipTemplate.DataTipRows(3) = dataTipTextRow('Batch#',blabel);
    end
    
else
    maxval = 0;
    for i = 1:NumOfBatches
        legendlabel{i} = ['B',num2str(ubatch(i))];
        colName = [options.label,'B',num2str(ubatch(i))];
        try
            pdfAll = fitdist(statsTable{:,colName},'Kernel','width',smoothValue);
            yAll = pdf(pdfAll,[0:1:100]);
        catch
            yAll = nan(length([0:1:100]),1);
        end
        try
            pdfClean = fitdist(statsTableClean{:,colName},'Kernel','width',smoothValue);
            yClean = pdf(pdfClean,[0:1:100]);
        catch
            yClean = nan(length([0:1:100]),1);
        end
        plotAll(i) = plot(axishandle,[0:1:100],yAll,'Color',[0.7,0.7,0.7],'LineStyle',':', 'LineWidth',1.5,'Marker','none', 'MarkerSize',6);
        hold(axishandle,"on");
        plotClean(i) = plot(axishandle,[0:1:100],yClean,'Color',cmap(i,:),'LineStyle','-', 'LineWidth',1.5,'Marker','none', 'MarkerSize',6);      
        maxval = max([maxval,max(yAll),max(yClean)]);
        tt(i,:) = prctile(statsTableClean{:,colName},[25,50,75]);
        
        if NumOfBatches==1, blabel = repmat({'All'},length(yAll),1); else blabel = ones(length(yAll),1)*ubatch(i); end       
        plotClean(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('Batch#',blabel);
        plotClean(i).DataTipTemplate.DataTipRows(2) = [];
        dummy = repmat({' '},length(yAll),1);
        plotAll(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(' ',dummy);
        plotAll(i).DataTipTemplate.DataTipRows(2) = [];
    end
    
end



tmp = median(tt,1);

aa = plot(axishandle,[tmp(1),tmp(1)],[0,maxval],'Color','k','LineStyle',':','LineWidth',2);
bb = plot(axishandle,[tmp(3),tmp(3)],[0,maxval],'Color','k','LineStyle',':','LineWidth',2);          
cc = plot(axishandle,[tmp(2),tmp(2)],[0,1.01*maxval],'Color','k','LineStyle','--','LineWidth',2);
text(axishandle,tmp(1),1.02*maxval,sprintf('LQ: %.2f',tmp(1)),'HorizontalAlignment','right');                    
text(axishandle,tmp(3),1.02*maxval,sprintf('UQ: %.2f',tmp(3)),'HorizontalAlignment','left');
text(axishandle,tmp(2),1.06*maxval,sprintf('Median: %.2f',tmp(2)),'HorizontalAlignment','center');

aa.DataTipTemplate.DataTipRows(2) = [];
aa.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});
bb.DataTipTemplate.DataTipRows(2) = [];
bb.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});
cc.DataTipTemplate.DataTipRows(2) = [];
cc.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});

MinorXTicks = [0:5:100];
XTicks = [0,10,20,30,40,50,60,70,80,90,100,107.5];
XTicksLabel = {'0','10','20','30','40','50','60','70','80','90','100','>100'};

axishandle.XTick = XTicks;
axishandle.XTickLabel = XTicksLabel;
axishandle.XAxis.MinorTickValues = MinorXTicks;
axishandle.XAxis.MinorTick='on';
axishandle.XMinorGrid = 'on';
axishandle.XGrid = 'on';
axishandle.YGrid = 'on';
axishandle.MinorGridLineStyle = '-';
axishandle.MinorGridAlpha = 0.2;

xlabel(axishandle,['% ',options.label]);

if strcmp(options.plotType,'histogram') 
    ylabel(axishandle,'Feature Count');                 
else
    axishandle.YTickLabel = [];
    ylabel(axishandle,'Relative Probability Density');
end
 
try
    axishandle.YLim = [0,1.1*maxval];
catch
    axishandle.YLim = [0,1];
end
if strcmp(options.split,'all')
    legend(axishandle,plotClean,'All');
else
    legend(axishandle,plotClean,legendlabel);
end
end
