function [t,y,toutlier] = OutlierFilter(t,y,polyfunc,polyCI,options)

arguments
       t
       y
       polyfunc
       polyCI
       options.lowonly (1,:) logical = false
    end

try
    switch polyfunc
        case 'none'
            toutlier = [];
            return;
        case 'prctile'
            Cent = prctile(y,[25 75]);
            iqr = Cent(2) - Cent(1);
            low_lim = Cent(1) - 1.5*iqr;
            up_lim = Cent(2) + 1.5*iqr;            
            cut_up = y > up_lim;
            cut_low = y < low_lim;           
        otherwise
            warning off
            try
                mdl = fit(t,y,polyfunc,'Robust','Bisquare');
            catch
                mdl = fit(t,y,'poly1','Robust','Bisquare');
            end
            warning on   
            ci = predint(mdl,t,polyCI,'observation','off');
            cut_up = y > ci(:,2);
            cut_low = y < ci(:,1);       
    end
    if options.lowonly
        outlier = cut_low;
    else
        outlier = or(cut_up,cut_low);
    end
    toutlier = t(outlier);
    y(outlier) = [];
    t(outlier) = [];
catch
    toutlier = [];
end

% if ~isempty(toutlier)
%     [t,y,tt] = OutlierFilter(t,y,polyfunc,polyCI);
%     toutlier = [toutlier;tt];
% end

end







