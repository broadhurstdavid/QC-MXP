function [rsdQC,dRatio,rsdREF,blankRatio,rsdSample] = calcStats(y,isQC,isBlank,isReference,options)

arguments
    y
    isQC {mustBeNumericOrLogical}
    isBlank {mustBeNumericOrLogical}
    isReference {mustBeNumericOrLogical}
    options.Logged {mustBeNumericOrLogical} = true
    options.Parametric {mustBeNumericOrLogical} = true
    options.BlankRatioMethod {mustBeMember(options.BlankRatioMethod,{'QC','Median','Percentile'})} = 'QC'
    options.RelativeLOD {mustBeGreaterThanOrEqual(options.RelativeLOD,1)} = 1.5;
end


% NOTE 'Logged' indicates whether the data has already been log transformed
% and thus we reverse that transformation before calculating RSD as is
% standard practice.

%yQCx = y(isQC);
%ySx = y(~isQC & ~isReference & ~isBlank);



if options.Logged
    y = power(10,y);
end



yQC = y(isQC);
yS = y(~isQC & ~isReference & ~isBlank);
yR = y(isReference);
yB = y(isBlank);



if options.Parametric
    rsdQC = 100 * std(yQC,'omitnan')./mean(yQC,'omitnan');
    rsdREF = 100 * std(yR,'omitnan')./mean(yR,'omitnan');
    rsdSample = 100 * std(yS,'omitnan')./mean(yS,'omitnan');
    dRatio = 100*rsdQC./rsdSample;
else
    rsdQC = 100 * 1.4826 * mad(yQC,1)./median(yQC,'omitnan');
    rsdREF = 100 * 1.4826 * mad(yR,1)./median(yR,'omitnan');
    rsdSample = 100 * 1.4826 * mad(yS,1)./median(yS,'omitnan');
    dRatio = 100*rsdQC./rsdSample;
end

switch options.BlankRatioMethod
    case 'QC'
        blankRatio = 100 * max(yB,[],'omitnan')/median(yQC,'omitnan');
    case 'Median'
        blankRatio = 100 * max(yB,[],'omitnan')/median(y(~isBlank),'omitnan');
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

if sum(~isnan(yR)) < 2
    rsdREF = NaN;
end

if sum(~isnan(yQC)) < 2
    rsdQC = NaN;
    dRatio = NaN;
    
end

if sum(~isnan(yS)) < 2
    dRatio = NaN;
    rsdSample = NaN;
end

end