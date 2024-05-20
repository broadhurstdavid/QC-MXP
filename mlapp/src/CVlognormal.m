function [CVraw] = CVlognormal(x)

sd = std(x);
a = ln(sd)^2;

CVraw = sqrt(a - 1);


end