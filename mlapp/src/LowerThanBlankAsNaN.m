function X = LowerThanBlankAsNaN(X,Xblank,thresh)
    if isempty(Xblank)
        return;
    end
    XblankThresh = thresh * max(Xblank,[],1,'omitnan');
    repXblankThresh = repmat(XblankThresh,height(X),1);
    badData = X < repXblankThresh;
    X(badData) = NaN;
end