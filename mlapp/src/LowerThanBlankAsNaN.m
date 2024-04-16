function X = LowerThanBlankAsNaN(X,Xblank,thresh)
    XblankThresh = thresh * max(Xblank,[],1,'omitnan');
    repXblankThresh = repmat(XblankThresh,height(X),1);
    badData = X < repXblankThresh;
    X(badData) = NaN;
end