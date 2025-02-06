function controlChart(axishandle,Data,option)

            arguments
                axishandle
                Data
                option.before = true
                option.cmap = lines
                option.title = ''
                option.islog = true;
                option.RelativeLOQ = 1.5
                option.WithinBatchCorrectionMode = 'QC'
            end
            
            isbatch = false;

            if strcmp(option.cmap,'batch')
                cols = {[0, 150, 255]./255,[125, 249, 255]./255};
                labels = [true,false];
                hash = containers.Map(labels,cols);
                tt = logical(rem(unique(Data.Batch),2));
                cmap = arrayfun(@(x) hash(x),tt,'UniformOutput',false);
                cmap = cell2mat(cmap);
                isbatch = true;
            else
                cmap = option.cmap;
            end

            ms = 6;
            lw = 2;   

            Label = Data.SampleType;
            index = ismember(Label,'Sample');
            Label(index) = Data.Label(index);

            if option.before
                y = Data.Y;
                spline = Data.Yspline;
            else
                y = Data.Z;
                if strcmp(option.WithinBatchCorrectionMode,'Sample')
                    mpv = median(Data.Y(Data.Sample),'omitnan');
                else
                    mpv = mean(Data.Y(Data.QC),'omitnan');
                end
                spline = repmat(mpv,numel(y),1);
            end
            
            t = Data.Order;
            youtlier = y(Data.Outlier);
            ttoutlier = t(Data.Outlier);
            batches = unique(Data.Batch);
            batchNumTotal = numel(batches);

            if ismac
                if batchNumTotal < 3
                    dot_size = 6;
                elseif batchNumTotal < 5
                    dot_size = 5;
                elseif batchNumTotal < 10
                    dot_size = 4;
                else
                    dot_size = 2;
                end
            else
                if batchNumTotal < 3
                    dot_size = 6;
                elseif batchNumTotal < 5
                    dot_size = 5;
                elseif batchNumTotal < 10
                    dot_size = 4;
                else
                    dot_size = 3;
                end
            end
            
            temp = y(Data.Blank);
            if isempty(temp)
                temp = NaN;
            else
                if option.islog
                    temp = power(10,temp);
                    temp = max(temp,[],1,'omitnan');
                    temp = temp*option.RelativeLOQ;
                    temp = log10(temp);
                else
                    temp = max(temp,[],1,'omitnan');
                    temp = temp*option.RelativeLOQ;
                end
            end
            

            cla(axishandle);
            hold(axishandle,'on');

            if option.before  
                f = line(axishandle,[t(1) t(end)],[temp temp],'LineStyle',':','Color','m','LineWidth',lw-1); 
                f.PickableParts = 'none';
            end            
            
            grps = unique(Label);

            tf = ismember(grps,{'Blank','QC','Reference'});
            grps = [grps(tf);grps(~tf)];
            numx = sum(tf);

            if option.before
                if sum(Data.Outlier) > 0
                    h = plot(axishandle,ttoutlier,youtlier,'ks','MarkerSize',dot_size+4,'MarkerFaceColor','k','LineWidth',lw);
                    h.DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(Data.Outlier));
                    h.DataTipTemplate.DataTipRows(2) = dataTipTextRow('Outlier',repmat({''},size(h.XData)));
                end
            end        
            count = 1;
            numOfGrps = length(grps);
            for i = 1:numOfGrps
                index = ismember(Label,grps(i));
                if ismember('QC',grps(i))
                    b(i) = plot(axishandle,t(index),y(index),'ko','MarkerFaceColor','r','MarkerSize',dot_size);                    
                elseif ismember('Blank',grps(i))
                    b(i) = plot(axishandle,t(index),y(index),'ko','MarkerFaceColor','m','MarkerSize',dot_size); 
                elseif ismember('Reference',grps(i))
                    b(i) = plot(axishandle,t(index),y(index),'ko','MarkerFaceColor','y','MarkerSize',dot_size); 
                else
                    b(i) = plot(axishandle,t(index),y(index),'s','MarkerEdgeColor','k','MarkerFaceColor',cmap(count,:),'MarkerSize',dot_size+1);
                    count = count+1;
                end
                b(i).DataTipTemplate.DataTipRows(1) = dataTipTextRow('SampleID:',Data.SampleID(index));
                b(i).DataTipTemplate.DataTipRows(2) = dataTipTextRow('Label:',Label(index));
            end
            
           % if option.before
                for i = 1:batchNumTotal
                    s(i) = plot(axishandle,t(Data.Batch==batches(i)),spline(Data.Batch==batches(i)),'r--','MarkerSize',ms,'LineWidth',lw-1);
                    s(i).PickableParts = 'none';
                end
                
               
                if isbatch
                    h = legend(axishandle,b(1:numx),grps(1:numx));
                else
                    h = legend(axishandle,b,grps);
                end
                pos = get(h,'Position');
                posx = 0.92;
                posy = 0.46;
                set(h,'Position',[posx posy pos(3) pos(4)]);
            % else
            %       for i = 1:batchNumTotal
            %           batchLabel = Label(Data.Batch==batches(i));
            %           batchY = y(Data.Batch==batches(i));
            %           batcht = t(Data.Batch==batches(i));
            %           index = ismember(batchLabel,'QC');
            %           ytemp = batchY(index);
            %           batchMPV = median(ytemp);
            %           tt = batcht(index);               
            %           s(i) = plot(axishandle,[tt(1) tt(end)],[batchMPV batchMPV],'r--','MarkerSize',ms,'LineWidth',lw-1);
            %           s(i).PickableParts = 'none';
            %       end
            % end

            if ~all(isnan(y))
            axis(axishandle,[min(t)-1, max(t)+1, 0.99*min([Data.Y;Data.Z],[],'omitnan'),1.01*max([Data.Y;Data.Z],[],'omitnan')]);
            end

            
            xlabel(axishandle, 'Injection order')
            if option.islog
                ylabel(axishandle, 'log_{10}(Feature Value)')
            else
                ylabel(axishandle, 'Feature Value')
            end
  
            hold(axishandle,'off');
            title(axishandle,option.title);
end