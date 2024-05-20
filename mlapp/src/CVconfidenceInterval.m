function [CV,upperbound,lowerbound] = CVconfidenceInterval(x,alpha,islog)

x(isnan(x)) = [];

n = length(x);
u1 = chi2inv(1-(alpha/2),n-1);
u2 = chi2inv(alpha/2,n-1);

if islog   
    ss = var(log(x));
    al = (n-1)*ss/u1;
    au = (n-1)*ss/u2;
    CV = sqrt(exp(ss)-1);
    lowerbound = sqrt(exp(al)-1);
    upperbound = sqrt(exp(au)-1);
else
    m = mean(x);
    ss = std(x);
    CV = ss/m;

    u1 = chi2inv(1-alpha/2,n-1);
    u2 = chi2inv(alpha/2,n-1);
    
    tt1 =(((u1+2)/n) - 1)*CV^2;
    ss1 = u1/(n-1);
    tt2 = (((u2+2)/n) - 1)*CV^2;
    ss2 = u2/(n-1);
    
    lowerbound = CV/sqrt(tt1 + ss1);
    upperbound = CV/sqrt(tt2 + ss2);
end



end