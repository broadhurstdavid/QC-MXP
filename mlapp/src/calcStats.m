function [rsdQC,rsdQClower,rsdQCupper,rsdSAMPLE,rsdSAMPLElower,rsdSAMPLEupper,rsdREF,rsdREFlower,rsdREFupper,dRatio,blankRatio,sampleMissingPerc,qcMissingPerc] = calcStats(y,isQC,isSample,isBlank,isReference,options)

arguments
    y
    isQC {mustBeNumericOrLogical}
    isSample {mustBeNumericOrLogical}
    isBlank {mustBeNumericOrLogical}
    isReference {mustBeNumericOrLogical}
    options.Logged {mustBeNumericOrLogical} = true
    options.BlankRatioMethod {mustBeMember(options.BlankRatioMethod,{'QC','Median','Percentile'})} = 'QC'
    options.RelativeLOQ {mustBeGreaterThanOrEqual(options.RelativeLOQ,1)} = 1.5;
end

% NOTE 'Logged' indicates whether the data has already been log transformed
% and thus we reverse that to calculate the statistics.

yQC = y(isQC);
yS = y(isSample);
yR = y(isReference);
yB = y(isBlank);

if options.Logged
    yB = power(10,yB);
    yQC = power(10,yQC);
    yS = power(10,yS);
    yR = power(10,yR);
end

sampleMissingPerc = 100 * sum(isnan(yS))./height(yS);
qcMissingPerc = 100 * sum(isnan(yQC))./height(yQC);

if options.Logged
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yQC,0.05,true);
    rsdQC = 100*cv; rsdQClower = 100*lowerbound; rsdQCupper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yR,0.05,true);
    rsdREF = 100*cv; rsdREFlower = 100*lowerbound; rsdREFupper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yS,0.05,true);
    rsdSAMPLE = 100*cv; rsdSAMPLElower = 100*lowerbound; rsdSAMPLEupper = 100*upperbound;
    dRatio = 100*rsdQC/rsdSAMPLE;
else
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yQC,0.05,false);
    rsdQC = 100*cv; rsdQClower = 100*lowerbound; rsdQCupper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yR,0.05,false);
    rsdREF = 100*cv; rsdREFlower = 100*lowerbound; rsdREFupper = 100*upperbound;
    [cv,upperbound,lowerbound] = CVconfidenceInterval(yS,0.05,false);
    rsdSAMPLE = 100*cv; rsdSAMPLElower = 100*lowerbound; rsdSAMPLEupper = 100*upperbound;
    dRatio = 100*rsdQC/rsdSAMPLE;
end


switch options.BlankRatioMethod  
    case 'QC'
        blankRatio = 100 * max(yB,[],'omitnan')/mean(yQC,'omitnan');
    case 'Median'
        blankRatio = 100 * max(yB,[],'omitnan')/median(yS,'omitnan');
    case 'Percentile'
        if isempty(yB)
            blankRatio = [];            
        else
            bb = max(yB,[],'omitnan')*options.RelativeLOQ;
            if isnan(bb)
                blankRatio = NaN;
            else
                cc = yS(~isnan(yS)) > bb;
                blankRatio = 100 * (1 - sum(cc)/length(yS));
            end
        end
    otherwise
        baseException = MException('QCRSC:UnexpectedBlankRatioMethod',"BlankRatioMethod value must be one of the following: 'QC','Median','Percentile'");
        throw(baseException)
end

if isempty(blankRatio)
    blankRatio = NaN;
end

if sum(~isnan(yR)) < 3
    rsdREF = NaN;
    rsdREFlower = NaN;
    rsdREFupper = NaN;
end

if sum(~isnan(yQC)) < 3
    rsdQC = NaN;
    rsdQClower = NaN;
    rsdQCupper = NaN;
    dRatio = NaN;
    
end

if sum(~isnan(yS)) < 3
    rsdSAMPLE = NaN;
    rsdSAMPLElower = NaN;
    rsdSAMPLEupper = NaN;
end

end