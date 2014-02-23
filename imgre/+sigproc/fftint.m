function [out] = fftint(x, fs, varargin )
%FFTINT 

if nargin > 2
    dim = varargin{1};
else
    dim = 1;
end

NFFT = size(x, dim);

% dop = (0:NFFT-1).*2*pi*1i*fs/NFFT;
% dop(NFFT/2+1:NFFT) = -dop(NFFT/2+1:NFFT);
% dop = shiftdim(transpose(fftshift(dop)), -(dim - 1));
dop = -(-NFFT/2:NFFT/2-1).*2*pi*1i*fs/NFFT;
dop = shiftdim(transpose(dop), -(dim - 1));

out = bsxfun(@rdivide, x, dop);
out(NFFT/2+1) = x(NFFT/2+1);

end

