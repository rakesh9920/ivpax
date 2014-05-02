function [ds] = dsflat(r)
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
a = 0.002512917929410;
c = 1540;

k = 2*pi*f/c;
r0 = k*a^2/(2*pi);
rat = r/r0;

if rat <= 1
    ds = 4*pi/(k*a)^2;
else
    ds = 4*pi/(k*a)^2*pi^2*Einf*rat^(-2)*exp(-Einf*pi*rat^(-2));
end

end