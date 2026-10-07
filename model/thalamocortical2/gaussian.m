function [data, f, mean] = gaussian(x,data)
f = fit(x.',data.','gauss1');
data = f.a1*exp(-((x-f.b1)./f.c1).^2);
mean = f.b1;
% f = fit(x.',data.','gauss2');
% data = f.a1*exp(-((x-f.b1)./f.c1).^2) + f.a2*exp(-((x-f.b2)./f.c2).^2);
% mean = [f.b1 f.b2];