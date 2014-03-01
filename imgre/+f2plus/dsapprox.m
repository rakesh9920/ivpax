function [ds] = dsapprox(r)
%DSAPPROX

fs = 100e6;
nfft = 2^13;
deltaF =fs/nfft;
f = (-nfft/2:nfft/2-1).*deltaF;

nrat = length(r);
nf = length(f);

ds = zeros(nrat, nf);

for ridx = 1:nrat
    for fidx = 1:nf
        
        ds(ridx, fidx) = approx(r(ridx), f(fidx)); 
    end
end


%ds = arrayfun(@approx, ratf);

% ds = zeros(size(rat,2), size(f, 2));
%
% for i = 1:size(rat,2)
%     if ~isscalar(f)
%         ds(i,:) = arrayfun(@approx, repmat(rat(i), size(f)), f);
%     else
%         ds(i,:) = approx(rat, f);
%     end
% end

end

function [ds] = approx(r, f)

Einf = 0.46;
a = 0.0025;
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