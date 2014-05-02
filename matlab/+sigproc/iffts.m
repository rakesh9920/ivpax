function [out] = iffts(varargin)
%IFFTS Inverse Fourier transform for Fourier transform scaled to give the
%spectral density.

fs = varargin{end};
Inputs = varargin(1:(end-1));
Inputs{1} = ifftshift(Inputs{1});

out = ifft(Inputs{:}).*fs;

end

