function [z,yspline] = QCRSC3(t,y,qc,mpv,epsilon,gammaVal,toutlier,CorrectionType,OutlierPostHoc)

tqc = t(qc);
yqc = y(qc);
ts = t(~qc);
ys = y(~qc);
found = ismember(tqc,toutlier);
tqc(found) = [];
yqc(found) = [];
myqc = 1;

try
    if isnan(gammaVal)
        myqc = mean(yqc,'omitnan');
        if isnan(myqc)
            myqc = mpv;
        end
        yspline = myqc*ones(length(t),1);
    elseif gammaVal == 1000
        mdl = fit(tqc,yqc,'poly1','Robust','Bisquare');
        yspline = feval(mdl,t);
    elseif gammaVal == 10000
        mdl = fit(ts,ys,'poly1','Robust','Bisquare');
        yspline = feval(mdl,t);
    else
        p = 1/(1+epsilon*10^(gammaVal));
        yspline = csaps(tqc,yqc,p,t);
    end
catch
    % if everything fails then don't correct at all.
    yspline = mpv*ones(length(t),1);
end

switch CorrectionType
    case 'Subtract'
            z = (y-yspline)+mpv;
    case 'Divide'
            z = (y./yspline).*mpv;
    otherwise
        ME = MException('QCRSC:UnexpectedQCRSCoperator',"QCRSC Operator '%s' does not exist",CorrectionType);
        throw(ME);
end

found = ismember(t,toutlier);
switch OutlierPostHoc
    case 'Ignore'
    case 'MPV'
        z(found) = mpv;
    case 'NaN'
        z(found) = nan;
    otherwise
        ME = MException('QCRSC:UnexpectedQCRSCoutlierAction',"QCRSC OutlierAction '%s' does not exist",OutlierPostHoc);
        throw(ME);
end

end