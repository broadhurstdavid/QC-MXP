function [imputedX,count] = incrementalKNNimpute(X,k)
    [~,idx]=sort(sum(isnan(X)));
    Xsorted = X(:,idx);
    count = width(Xsorted);
    num_missing = count;
    while num_missing > 0
        count = count-1;
        num_missing = sum(sum(isnan(Xsorted(:,1:count))));
    end
    for i = count+1:width(Xsorted)
        XT = knnimpute(Xsorted(:,1:i),k);
        Xsorted(:,1:i) = XT;
    end
    imputedX(:,idx) = Xsorted;
end