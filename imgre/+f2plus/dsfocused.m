function [ds] = dsfocused(r, f)
%DSFOCUSED

import f2plus.lommel1 f2plus.lommel2

c = 1540;
a = 0.0025;
N = 100;

k = 2*pi*f/c;
Y = k*a^2/r;

Z1 = 0;
Z2 =  k*a;

integr = @(Z) (8.*((lommel1(Y,Z,N).*Z./Y).^2 + (lommel2(Y,Z,N).*Z./Y).^2).^2)./Z.^3.*sqrt(1-(Z./(k*a)).^2);

ds = pi*a^2/r^2*integral(integr, Z1, Z2);


end

