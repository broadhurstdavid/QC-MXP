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
            [~,cent,scle] = normalize(Z0,1,'center');
            ZZout(in,:) = (ZZsub-cent)./sqrt(scle);
    end
end



end