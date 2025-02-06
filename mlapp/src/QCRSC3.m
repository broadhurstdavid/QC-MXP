function [z,yspline] = QCRSC3(t,y,isQC,isSample,mpv,epsilon,gammaVal,toutlier,CorrectionType,OutlierPostHoc)

tqc = t(isQC);
yqc = y(isQC);
ts = t(isSample);
ys = y(isSample);
found = ismember(tqc,toutlier);
tqc(found) = [];
yqc(found) = [];
missingQC = isnan(yqc);
tqc(missingQC) = [];
yqc(missingQC) = [];
missingSample = isnan(ys);
ts(missingSample) = [];
ys(missingSample) = [];

if gammaVal < 1000
    gammaVal = (gammaVal-5)/4; % this is to make the GUI scaling easier [0:1:25] = [-0.5:0.25:0.45]
end

try
    if isnan(gammaVal)
        myqc = median(yqc,'omitnan');
        if isnan(myqc)
            myqc = mpv;
        end
        yspline = myqc*ones(length(t),1);
    elseif gammaVal == 1000
        try
            mdl = fit(tqc,yqc,'poly1','Robust','Bisquare');
        catch
            mdl = fit(tqc,yqc);
        end
        yspline = feval(mdl,t);
    elseif gammaVal == 10000
        try
            mdl = fit(ts,ys,'poly1','Robust','Bisquare');
        catch
            mdl = fit(ts,ys,'poly1');
        end
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