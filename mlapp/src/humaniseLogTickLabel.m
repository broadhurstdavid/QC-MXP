function [labelOut] = humaniseLogTickLabel(labelIn)
    
 keySet = {'10^{-3}','10^{-2}','10^{-1}','10^{0}','10^{1}','10^{2}','10^{3}'};
 valueSet = {'0.001','0.01','0.1','1','10','100','1000'};
 M = containers.Map(keySet,valueSet);
 labelOut = cellfun(@(x)mapOnlyValid(M,x),labelIn,'uniformoutput',0);
 
 
    function value = mapOnlyValid(MM,key)
        if isKey(MM,key)
            value = MM(key);
        else
            value = key;
        end
    end


end

