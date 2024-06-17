function [ZZout] = batchScale(ZZ,isSample,batchnum,type)
ZZout = ZZ;
uniqueBatch = unique(batchnum);
for i = 1:length(uniqueBatch)
    in = batchnum == uniqueBatch(i);
    ZZsub = ZZ(in,:);
    isSampleSub = isSample(in);
    Z0 = ZZsub(isSampleSub,:);
    switch type
        case 'autoscale'
            [~,cent,scle] = normalize(Z0,1,'zscore');
            ZZout(in,:) = (ZZsub-cent)./scle;
        case 'pareto'
            [~,cent,scle] = normalize(Z0,1,'zscore');
            ZZout(in,:) = (ZZsub-cent)./sqrt(scle);
        otherwise
            error('no such scale type');
    end
end



end