function [rsdQC,rsdSAMPLE,dRatio,rsdREF,blankRatio] = calcStats(y,isQC,isBlank,isReference,options)

arguments
    y
    isQC {mustBeNumericOrLogical}
    isBlank {mustBeNumericOrLogical}
    isReference {mustBeNumericOrLogical}
    options.Logged {mustBeNumericOrLogical} = true
    options.BlankRatioMethod {mustBeMember(options.BlankRatioMethod,{'QC','Median','Percentile'})} = 'QC'
    options.RelativeLOD {mustBeGreaterThanOrEqual(options.RelativeLOD,1)} = 1.5;
end

% NOTE 'Logged' indicates whether the data has already been log transformed
% and thus we reverse that to calculate the statistics.

yQC = y(isQC);
yS = y(~isQC & ~isReference & ~isBlank);
yR = y(isReference);
yB = y(isBlank);

if options.Logged
    yB = power(10,yB);
    yQC = power(10,yQC);
    yS = power(10,yS);
    yR = power(10,yR);
end

if options.Logged
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yQC,0.05,true);
    rsdQC.mean = 100*cv; rsdQC.lower = 100*lowerbound; rsdQC.upper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yR,0.05,true);
    rsdREF.mean = 100*cv; rsdREF.lower = 100*lowerbound; rsdREF.upper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yS,0.05,true);
    rsdSAMPLE.mean = 100*cv; rsdSAMPLE.lower = 100*lowerbound; rsdSAMPLE.upper = 100*upperbound;
    dRatio = 100*rsdQC.mean/rsdSAMPLE.mean;
else
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yQC,0.05,false);
    rsdQC.mean = 100*cv; rsdQC.lower = 100*lowerbound; rsdQC.upper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yR,0.05,false);
    rsdREF.mean = 100*cv; rsdREF.lower = 100*lowerbound; rsdREF.upper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yS,0.05,false);
    rsdSAMPLE.mean = 100*cv; rsdSAMPLE.lower = 100*lowerbound; rsdSAMPLE.upper = 100*upperbound;
    dRatio = 100*rsdQC.mean/rsdSAMPLE.mean;
end


switch options.BlankRatioMethod  
    case 'QC'
        blankRatio = 100 * max(yB,[],'omitnan')/mean(yQC,'omitnan');
    case 'Median'
        blankRatio = 100 * max(yB,[],'omitnan')/median(yS,'omitnan');
    case 'Percentile'
        if isempty(yB)
            blankRatio = 100 * (1 - sum(isnan(yS))/length(yS));            
        else
            bb = max(yB,[],'omitnan')*options.RelativeLOD;
            cc = yS(~isnan(yS)) > bb;
            blankRatio = 100 * (1 - sum(cc)/length(yS));
        end
    otherwise
        baseException = MException('QCRSC:UnexpectedBlankRatioMethod',"BlankRatioMethod value must be one of the following: 'QC','Median','Percentile'");
        throw(baseException)
end

if isempty(blankRatio)
    blankRatio = NaN;
end

if sum(~isnan(yR)) < 3
    rsdREF.mean = NaN;
    rsdREF.lower = NaN;
    rsdREF.upper = NaN;
end

if sum(~isnan(yQC)) < 3
    rsdQC.mean = NaN;
    rsdQC.lower = NaN;
    rsdQC.upper = NaN;
    dRatio = NaN;
    
end

if sum(~isnan(yS)) < 3
    rsdSAMPLE.mean = NaN;
    rsdSAMPLE.lower = NaN;
    rsdSAMPLE.upper = NaN;
end

end