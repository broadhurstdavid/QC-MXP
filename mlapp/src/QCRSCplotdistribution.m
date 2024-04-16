function [] = QCRSCplotdistribution(axishandle,statsTable,BatchVector,options)

    arguments
       axishandle {mustBeA(axishandle,'matlab.ui.control.UIAxes')}
       statsTable {mustBeA(statsTable,'table')}
       BatchVector {mustBeInteger,mustBePositive}
       options.plotType {mustBeMember(options.plotType,{'histogram','pdf'})} = 'histogram'  
       options.split {mustBeMember(options.split ,{'all','batch'})} = 'all'
       options.smooth {mustBeNumeric,mustBeInRange(options.smooth,0,100)} = 20
       options.label {mustBeA(options.label,{'char','string'})} = 'qcRSD'
       options.cmap = lines; 
    end

cmap = mapRcolors('quoka');
smoothValue = (options.smooth+10)/600;

cla(axishandle,'reset');
edges = [-1.125:0.25:3.125];
center = edges(1:end-1) + diff(edges) / 2;

ubatch = unique(BatchVector);
NumOfBatches = numel(ubatch);

if strcmp(options.split,'all')
    ubatch = 1;
    NumOfBatches = 1;
    statsTable(:,[options.label,'B1']) = statsTable(:,options.label); 
end

statsTableClean = statsTable(statsTable.cleanPeaks,:);

if strcmp(options.plotType,'histogram')   
    for i = 1:NumOfBatches
        legendlabel{i} = ['B',num2str(ubatch(i))];
        colName = [options.label,'B',num2str(ubatch(i))];
        nAll(i,:) = histcounts(log10(statsTable{:,colName}),edges);
        nClean(i,:) = histcounts(log10(statsTableClean{:,colName}),edges);
        tt(i,:) = prctile(statsTableClean{:,colName},[25,50,75]);
    end
    plotAll = bar(axishandle,center,nAll','FaceColor','w','EdgeColor','k');
    hold(axishandle,"on");
    plotClean = bar(axishandle,center,nClean');
    for i = 1:numel(plotClean)
        plotClean(i).FaceColor = cmap(i,:);
    end

    maxval = max(max(nAll));

    tmp = string((round(10*power(10,edges))/10));
    temp = cellfun(@(x,y) strcat('(',x,'<x<',y,')'),tmp(1:end-1),tmp(2:end),'UniformOutput',false);   
    for i = 1:NumOfBatches
        if NumOfBatches ==1, blabel = repmat({'All'},length(center),1); else blabel = ones(length(center),1)*ubatch(i); end       
        plotAll(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,temp);
        plotAll(i).DataTipTemplate.DataTipRows(2).Label = '#Peaks';
        plotAll(i).DataTipTemplate.DataTipRows(3) = dataTipTextRow('Batch#',blabel);
        plotClean(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow(options.label,temp);
        plotClean(i).DataTipTemplate.DataTipRows(2).Label = '#Peaks';
        plotClean(i).DataTipTemplate.DataTipRows(3) = dataTipTextRow('Batch#',blabel);
    end
    
else
    maxval = 0;
    for i = 1:NumOfBatches
        legendlabel{i} = ['B',num2str(ubatch(i))];
        colName = [options.label,'B',num2str(ubatch(i))];
        pdfAll = fitdist(log10(statsTable{:,colName}),'Kernel','width',smoothValue);
        yAll = pdf(pdfAll,[-1:0.1:3]);
        pdfClean = fitdist(log10(statsTableClean{:,colName}),'Kernel','width',smoothValue);
        yClean = pdf(pdfClean,[-1:0.1:3]);
        plotAll(i) = plot(axishandle,[-1:0.1:3],yAll,'Color',[0.7,0.7,0.7],'LineStyle',':', 'LineWidth',1.5,'Marker','none', 'MarkerSize',6);
        hold(axishandle,"on");
        plotClean(i) = plot(axishandle,[-1:0.1:3],yClean,'Color',cmap(i,:),'LineStyle','-', 'LineWidth',1.5,'Marker','none', 'MarkerSize',6);      
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

aa = plot(axishandle,[log10(tmp(1)),log10(tmp(1))],[0,maxval],'Color','k','LineStyle',':','LineWidth',2);
bb = plot(axishandle,[log10(tmp(3)),log10(tmp(3))],[0,maxval],'Color','k','LineStyle',':','LineWidth',2);          
cc = plot(axishandle,[log10(tmp(2)),log10(tmp(2))],[0,1.01*maxval],'Color','k','LineStyle','--','LineWidth',2);
text(axishandle,log10(tmp(1)),1.02*maxval,sprintf('LQ: %.2f',tmp(1)),'HorizontalAlignment','right');                    
text(axishandle,log10(tmp(3)),1.02*maxval,sprintf('UQ: %.2f',tmp(3)),'HorizontalAlignment','left');
text(axishandle,log10(tmp(2)),1.06*maxval,sprintf('Median: %.2f',tmp(2)),'HorizontalAlignment','center');

aa.DataTipTemplate.DataTipRows(2) = [];
aa.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});
bb.DataTipTemplate.DataTipRows(2) = [];
bb.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});
cc.DataTipTemplate.DataTipRows(2) = [];
cc.DataTipTemplate.DataTipRows(1) = dataTipTextRow('',{'',''});

MinorXTicks = [[0.1:0.1:1],[2:10],[20:10:100],[200:100:1000]];
XTicks = [0.1,1,10,100,1000];
XTicksLabel = {'<0.1','1','10','100','1000'};

axishandle.XTick = log10(XTicks);
axishandle.XTickLabel = XTicksLabel;
axishandle.XAxis.MinorTickValues = log10(MinorXTicks);
axishandle.XAxis.MinorTick='on';
axishandle.XMinorGrid = 'on';
axishandle.XGrid = 'on';
axishandle.YGrid = 'on';
axishandle.MinorGridLineStyle = '-';
axishandle.MinorGridAlpha = 0.2;

xlabel(axishandle,['% ',options.label,' (log scale)']);

if strcmp(options.plotType,'histogram') 
    ylabel(axishandle,'Peaks Count');                 
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
