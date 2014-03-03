function [ds] = dsfocused(r)
%DSAPPROX

fs = 100e6;
nfft = 2^13;
deltaF = fs/nfft;
f = (-nfft/2:nfft/2-1).*deltaF;

nr = length(r);
nf = length(f);

ds = zeros(nr, nf);

for ridx = 1:nr
    for fidx = 1:nf
        
        ds(ridx, fidx) = approx(r(ridx), f(fidx)); 
    end
end

end

function [ds] = approx(r, f)

Einf = 0.46;
% a = 0.002512917929410;
a = 0.0025;
c = 1540;
fc = 5e6;

k = 2*pi*f/c;
r0 = 0.02;
Gp = k*a^2/(2*r0);

gateLength = 3*c/fc;

r1 = (1 + pi/Gp)^-1;
r2 = (1 - pi/Gp)^-1;

if r/r0 >= r1 &&  r/r0 <= r2
    ds = (pi*a^2/r^2)*Einf*exp(-(Einf/pi)*Gp^2*(r0/r-1)^2);
else
    ds = (pi*a^2/r^2)*(Gp*(r0/r-1)^2)^(-2);
end

ds = ds./gateLength;

end