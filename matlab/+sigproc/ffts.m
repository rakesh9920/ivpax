function [out] = ffts(varargin)
%FFTS Fourier transform scaled to give the spectral density.

fs = varargin{end};
Inputs = varargin(1:(end-1));

out = fftshift(fft(Inputs{:}))./fs;

end

