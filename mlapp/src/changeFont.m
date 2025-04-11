function [h] = changeFont(h,name)

    if ~ismember(name,listfonts)
        disp('unknown font');
        return;
    end
    
    if isprop(h,'FontName')
        h.FontName = name; 
    end
    if isprop(h,'Children')
        cc = h.Children;
        for i = 1:length(cc)
            changeFont(cc(i),name);
        end
    end
end