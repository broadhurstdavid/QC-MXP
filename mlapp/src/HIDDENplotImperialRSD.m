function HIDDENplotImperialRSD(app)
            
            cla(app.UIAxesImperialRSD,'reset');
            
            bin = (1:height(app.PlotPeakTable))';
            if ismac
                ms = 9;
            else
                ms = 7;
            end
            grey = [0.7,0.7,0.7];

            if any(app.PlotDataTable.Reference)
                app.RefCheckBox.Enable = 'on';
            else
                app.RefCheckBox.Enable = 'off';
            end


            if strcmp(app.SortbySwitch.Value,'sample')
                [ss,index] = sortrows(app.PlotPeakTable.sampleRSD);
                qq = app.PlotPeakTable.qcRSD(index);
            else
                [qq,index] = sortrows(app.PlotPeakTable.qcRSD);
                ss = app.PlotPeakTable.sampleRSD(index);
            end
            dd = app.PlotPeakTable.dRatio(index);
            rr = app.PlotPeakTable.refRSD(index);
            bb = app.PlotPeakTable.blankRatio(index);
            id = app.PlotPeakTable.UID(index);
            
            customLabel = app.CustomLabelDropDownA1.Value;
            if strcmp(customLabel,'None')
                customflag = false;
            else
                customflag = true;
                cc = app.PlotPeakTable.(customLabel);
            end

            customLabel2 = app.CustomLabelDropDownA2.Value;
            if strcmp(customLabel2,'None') || customflag == false
                customflag2 = false;
                app.CustomLabelDropDownA2.Value = 'None';
            else
                customflag2 = true;
                cc2 = app.PlotPeakTable.(customLabel2);
            end

            in = app.PlotPeakTable.cleanPeaks(index);
            
            ll = [];
            lt = {};
            
           
            if any(~in)
                
                if strcmp(app.DeltaSwitch.Value,'overlay')

                    h2outA = semilogx(app.UIAxesImperialRSD,ss(~in),bin(~in),'.');
                    h2outA.MarkerSize = ms;
                    h2outA.MarkerFaceColor = grey;
                    h2outA.MarkerEdgeColor = grey;
                    h2outA.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(~in));
                    h2outA.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(~in),'%.2f');
                    if customflag, h2outA.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(~in)); end
                    if customflag2, h2outA.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(~in)); end
                    hold(app.UIAxesImperialRSD,"on");

                    h2outB = semilogx(app.UIAxesImperialRSD,qq(~in),bin(~in),'.');
                    h2outB.MarkerSize = ms;
                    h2outB.MarkerFaceColor = grey;
                    h2outB.MarkerEdgeColor = grey;
                    h2outB.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(~in));
                    h2outB.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(~in),'%.2f');
                    if customflag, h2outB.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(~in)); end
                    if customflag2, h2outB.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(~in)); end
                    if app.RefCheckBox.Value  
                        h2outC = semilogx(app.UIAxesImperialRSD,rr(~in),bin(~in),'.');                    
                        h2outC.MarkerSize = ms;
                        h2outC.MarkerFaceColor = grey;
                        h2outC.MarkerEdgeColor = grey;
                        h2outC.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(~in));
                        h2outC.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(~in));
                        h2outC.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(~in));
                        h2outC.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(~in));
                        h2outC.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(~in));
                        h2outC.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(~in),'%.2f');
                        if customflag, h2outC.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(~in)); end
                        if customflag2, h2outC.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(~in)); end
                    end
                else
                    h2outA = plot(app.UIAxesImperialRSD,ss(~in),bin(~in),'.');
                    h2outA.MarkerSize = ms;
                    h2outA.MarkerFaceColor = grey;
                    h2outA.MarkerEdgeColor = grey;
                    h2outA.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(~in));
                    h2outA.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(~in),'%.2f');
                    h2outA.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(~in),'%.2f');
                    if customflag, h2outA.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(~in)); end
                    if customflag2, h2outA.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(~in)); end
                    hold(app.UIAxesImperialRSD,"on");

                    delta = qq(~in) - rr(~in);
                    h2outB = semilogx(app.UIAxesImperialRSD,delta,bin(~in),'.');
                    h2outB.MarkerSize = ms;
                    h2outB.MarkerFaceColor = grey;
                    h2outB.MarkerEdgeColor = grey;
                    h2outB.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(~in));
                    h2outB.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(~in),'%.2f');
                    h2outB.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(~in),'%.2f');
                    if customflag, h2outB.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(~in)); end
                    if customflag2, h2outB.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(~in)); end
                end
            end 
            
            if any(in)
                
                
                if strcmp(app.DeltaSwitch.Value,'overlay')
                    h2inA = semilogx(app.UIAxesImperialRSD,ss(in),bin(in),'.');
                    h2inA.MarkerSize = ms;
                    h2inA.MarkerFaceColor = 'b';
                    h2inA.MarkerEdgeColor = 'b';
                    h2inA.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(in));
                    h2inA.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(3) = dataTipTextRow('sampleRSD:',ss(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(4) = dataTipTextRow('refRSD:',rr(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(in),'%.2f');
                    if customflag, h2inA.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(in)); end
                    if customflag2, h2inA.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(in)); end
                    hold(app.UIAxesImperialRSD,"on");

                    h2inB = semilogx(app.UIAxesImperialRSD,qq(in),bin(in),'.');
                    h2inB.MarkerSize = ms;
                    h2inB.MarkerFaceColor = 'r';
                    h2inB.MarkerEdgeColor = 'r';
                    h2inB.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(in));
                    h2inB.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(3) = dataTipTextRow('sampleRSD:',ss(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(4) = dataTipTextRow('refRSD:',rr(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(in),'%.2f');
                    if customflag, h2inB.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(in)); end
                    if customflag2, h2inB.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(in)); end
    
                    ll = [ll,h2inA,h2inB];
                    lt = [lt,{'Sample','QC'}];
                    
                    if app.RefCheckBox.Value  
                        h2inC = semilogx(app.UIAxesImperialRSD,rr(in),bin(in),'.');                    
                        h2inC.MarkerSize = ms;
                        h2inC.MarkerFaceColor = 'c';
                        h2inC.MarkerEdgeColor = 'c';
                        h2inC.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(in));
                        h2inC.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(in));
                        h2inC.DataTipTemplate.DataTipRows(3) = dataTipTextRow('refRSD:',rr(in));
                        h2inC.DataTipTemplate.DataTipRows(4) = dataTipTextRow('sampleRSD:',ss(in));
                        h2inC.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(in));
                        h2inC.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(in),'%.2f');
                        if customflag, h2inC.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(in)); end
                        if customflag2, h2inC.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(in)); end
    
                        ll = [ll,h2inC];
                        lt = [lt,{'Reference'}];
                    end
                else
                    h2inA = plot(app.UIAxesImperialRSD,ss(in),bin(in),'.');
                    h2inA.MarkerSize = ms;
                    h2inA.MarkerFaceColor = 'b';
                    h2inA.MarkerEdgeColor = 'b';
                    h2inA.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(in));
                    h2inA.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(3) = dataTipTextRow('sampleRSD:',ss(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(4) = dataTipTextRow('refRSD:',rr(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(in),'%.2f');
                    h2inA.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(in),'%.2f');
                    if customflag, h2inA.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(in)); end
                    if customflag2, h2inA.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(in)); end
                    hold(app.UIAxesImperialRSD,"on");

                    delta = qq(in) - rr(in);
                    h2inB = plot(app.UIAxesImperialRSD,delta,bin(in),'.');
                    h2inB.MarkerSize = ms;
                    h2inB.MarkerFaceColor = 'r';
                    h2inB.MarkerEdgeColor = 'r';
                    h2inB.DataTipTemplate.DataTipRows(1) = dataTipTextRow('UID:',id(in));
                    h2inB.DataTipTemplate.DataTipRows(2) = dataTipTextRow('qcRSD:',qq(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(3) = dataTipTextRow('sampleRSD:',ss(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(4) = dataTipTextRow('refRSD:',rr(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(5) = dataTipTextRow('Dratio:',dd(in),'%.2f');
                    h2inB.DataTipTemplate.DataTipRows(6) = dataTipTextRow('blankRatio:',bb(in),'%.2f');
                    if customflag, h2inB.DataTipTemplate.DataTipRows(7) = dataTipTextRow([customLabel,':'],cc(in)); end
                    if customflag2, h2inB.DataTipTemplate.DataTipRows(8) = dataTipTextRow([customLabel2,':'],cc2(in)); end
    
                    ll = [ll,h2inA,h2inB];
                    lt = [lt,{'Sample','QC - Reference'}];
                end
                
                if strcmp(app.DeltaSwitch.Value,'overlay')
                    if strcmp(app.SortbySwitch.Value,'sample')
                        k = ~isnan(qq) & in;
                        y = smooth(log10(qq(k)),0.8,'rloess');              
                        y = power(10,y);
                        %semilogx(app.UIAxesImperialRSD,y,bin(k),'r-.','LineWidth',3);
                        fx = semilogx(app.UIAxesImperialRSD,y,bin(k),'k--','LineWidth',2);
                        datatip(fx,'Visible','off');
                        fx.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Loess Mean QC-RSD','');
                        fx.DataTipTemplate.DataTipRows(2) = [];
                    else
                        k = ~isnan(ss) & in;
                        y = smooth(log10(ss(k)),0.8,'rloess');  
                        y = power(10,y);
                        %semilogx(app.UIAxesImperialRSD,y,bin(k),'b-.','LineWidth',3);
                        fx = semilogx(app.UIAxesImperialRSD,y,bin(k),'k--','LineWidth',2);
                        datatip(fx,'Visible','off');
                        fx.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Loess Mean Sample-RSD','');
                        fx.DataTipTemplate.DataTipRows(2) = [];
                    end
                                  
                    if app.RefCheckBox.Value        
                        k = ~(rr==0) & ~isnan(rr) & in;
                        y = smooth(log10(rr(k)),0.8,'rloess');  
                        y = power(10,y);
                        %semilogx(app.UIAxesImperialRSD,y,bin(k),'c-.','LineWidth',3);
                        fx = semilogx(app.UIAxesImperialRSD,y,bin(k),'k-.','LineWidth',2);
                        datatip(fx,'Visible','off');
                        fx.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Loess Mean Reference-RSD','');
                        fx.DataTipTemplate.DataTipRows(2) = [];
                    end
                else
                    if strcmp(app.SortbySwitch.Value,'sample')                        
                        delta = qq - rr;
                        k = ~isnan(delta) & in;
                        y = smooth(delta(k),0.8,'rloess');                                      
                        fx = plot(app.UIAxesImperialRSD,y,bin(k),'k--','LineWidth',2);
                        datatip(fx,'Visible','off');
                        fx.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Loess Mean delta-RSD','');
                        fx.DataTipTemplate.DataTipRows(2) = [];
                    else                      
                        k = ~isnan(ss) & in;
                        y = smooth(ss(k),0.8,'rloess');                         
                        %plot(app.UIAxesImperialRSD,y,bin(k),'b-','LineWidth',3);
                        %plot(app.UIAxesImperialRSD,y,bin(k),'k-','LineWidth',1);  
                        fx = plot(app.UIAxesImperialRSD,y,bin(k),'k--','LineWidth',2); 
                        datatip(fx,'Visible','off');
                        fx.DataTipTemplate.DataTipRows(1) = dataTipTextRow('Loess Mean Reference-RSD','');
                        fx.DataTipTemplate.DataTipRows(2) = [];
                    end                                 
                end

            end
            xlabel(app.UIAxesImperialRSD,'%RSD');
            ylabel(app.UIAxesImperialRSD,'Cumulative Number of Peaks');
            legend(app.UIAxesImperialRSD,ll,lt,'location','southeast');
            
            app.UIAxesImperialRSD.Box = 'on';
            ylim(app.UIAxesImperialRSD,[0,1.05*max(bin)])

            if strcmp(app.DeltaSwitch.Value,'overlay')
                app.UIAxesImperialRSD.XGrid = 'on';            
                app.UIAxesImperialRSD.YGrid = 'on';            
                app.UIAxesImperialRSD.MinorGridLineStyle = '-';
                app.UIAxesImperialRSD.MinorGridAlpha = 0.2;
                xlim(app.UIAxesImperialRSD,[0.9*min([qq;ss]),1.1*max([qq;ss])])                
                app.UIAxesImperialRSD.XTickLabel = humaniseLogTickLabel(app.UIAxesImperialRSD.XTickLabel);
            end
            app.UIAxesImperialRSD.ButtonDownFcn = createCallbackFcn(app, @UIAxesImperialRSDButtonDown, true);
        end