function [imputedX,count] = incrementalKNNimpute(X,k)
    [~,idx]=sort(sum(isnan(X)));
    Xsorted = X(:,idx);
    count = width(Xsorted);
    num_missing = count;
    while num_missing > 0
        try 
            XT = knnimpute(Xsorted(:,1:count),k);
            Xsorted(:,1:count) = XT;
            count = width(Xsorted);
        catch
            count = count-1;
        end
        num_missing = sum(sum(isnan(Xsorted)));
    end
    imputedX(:,idx) = Xsorted;
end