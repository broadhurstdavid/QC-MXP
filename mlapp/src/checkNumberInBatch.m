function [maxnum,minnum,numbatch,uniquebatch] = checkNumberInBatch(DataTable,ColHeader)
Data = DataTable.(ColHeader);
if ~isa(Data,"logical")
    baseException = MException('DataTableType','data column must be logical');
    throw(baseException);
end
uniquebatch = unique(DataTable.Batch);
for i = 1:length(uniquebatch)
    temp = Data(DataTable.Batch == uniquebatch(i));
    numbatch(i) = sum(temp);
end
maxnum = max(numbatch);
minnum = min(numbatch);

end