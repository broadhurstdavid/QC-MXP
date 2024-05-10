function [z,yspline] = QCRSC2(t,y,qc,mpv,epsilon,gammaVal,toutlier,CorrectionType,OutlierPostHoc)

tqc = t(qc);
yqc = y(qc);
found = ismember(tqc,toutlier);
tqc(found) = [];
yqc(found) = [];

try
    if isnan(gammaVal)
        yspline = mean(yqc,'omitnan')*ones(length(t),1);
    elseif gammaVal == 1000
        mdl = fit(tqc,yqc,'poly1','Robust','Bisquare');
        yspline = feval(mdl,t);
    else
        p = 1/(1+epsilon*10^(gammaVal));
        yspline = csaps(tqc,yqc,p,t);
    end
catch
    ME = MException('QCRSC:UnexpectedQCRSCerror',"QCRSC correction unexpectedly failed");
    throw(ME);
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