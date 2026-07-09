function [meanDeltaCV,upperbound,lowerbound,cvB,cvA] = bootstrapDeltaCVconfidenceInterval(exptBefore,exptAfter,alpha,islog)

% Combine into a single matrix
raw_matrix = [exptBefore,exptAfter];

% Clean rows listwise: removes any row containing a NaN
cleaned_matrix = rmmissing(raw_matrix); 

% Anonymous function for the change in CV

cvB = CVci(cleaned_matrix(:,1),islog);
cvA = CVci(cleaned_matrix(:,2),islog);

cv_diff_func = @(data) (CVci(data(:,1),islog) - CVci(data(:,2),islog));

%cv_diff_func = @(data) (std(data(:,2),0)/mean(data(:,2))) - (std(data(:,1),0)/mean(data(:,1)));

% Run built-in bootstrap on clean rows
[ci,bootstat] = bootci(1000, {cv_diff_func, cleaned_matrix}, 'Alpha', alpha, 'Type', 'per');

meanDeltaCV = mean(bootstat);
upperbound = ci(2);
lowerbound = ci(1);


end

function CV = CVci(x,islog)
    if islog   
        ss = var(log(x));
        CV = sqrt(exp(ss)-1);
    else
        m = mean(x);
        ss = std(x);
        CV = ss/m;
    end
end

