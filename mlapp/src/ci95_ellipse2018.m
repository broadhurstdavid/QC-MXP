function [x,y,x0,y0,outside,area] = ci95_ellipse2018(data,type)

% Build PCA model
% eigvals = eigen values = principal component variances
[coeff,score,eigvals] = pca(data);
% Calulate rotation angle
phi = atan2(coeff(2,1), coeff(1,1));
% This angle is between -pi and pi.
% Let's shift it such that the angle is between 0 and 2pi
if(phi < 0)
    phi = phi + 2*pi;
end

% Get the coordinates of the data mean
n = size(data,1);
m = mean(data);
x0=m(1);
y0=m(2);

% Get the 95% confidence interval error ellipse
% inverse of the chi-square cumulative distribution for  p = 0.05 & 2 d.f. = 5.9915 
chisquare_val = 5.9915;
if strcmp(type,'pop') 
    a=sqrt(chisquare_val*eigvals(1));
    b=sqrt(chisquare_val*eigvals(2));
elseif strcmp(type,'mean')
    a=sqrt(chisquare_val*eigvals(1)/n);
    b=sqrt(chisquare_val*eigvals(2)/n);
else
    error('unknown Type');
end
% the ellipse in x and y coordinates
theta_grid = linspace(0,2*pi);
ellipse_x_r  = a*cos( theta_grid );
ellipse_y_r  = b*sin( theta_grid );



%Define a rotation matrix
R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];
%let's rotate the ellipse to some angle phi
r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;

% Draw the error ellipse
x = r_ellipse(:,1) + x0;
y = r_ellipse(:,2) + y0;

outside = (score(:,1)/a).^2 + (score(:,2)/b).^2 > 1;

area = pi*a*b;

end

