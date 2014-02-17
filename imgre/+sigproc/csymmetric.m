function [out] = csymmetric(x)

NFFT = length(x);

out = x;

out(NFFT/2:-1:2) = conj(out(NFFT/2+2:NFFT));

end

