function [ output_args ] = calc_multi_custombsc( input_args )
%CALC_SCAT_MULTI_CUSTOM Summary of this function goes here
%   Detailed explanation goes here

% RfCell = num2cell(RfMat, 1);
% 
% out = cellfun(@(x) conv(x, A)./fs, RfCell, 'UniformOutput', false);
% out = cat(2, out{:});

% phi = zeros(6, 1);
% phi(4) = -2*pi*phi_mag/c/rho/SR*fs;
% fs = 100e6;
% phi = zeros(2000, 1);
% phi(1000) = 2*pi*phi_mag/c/rho/SR*fs;
% % % 
% % % A = (diff(phi).*fs);
% PHI = ffts(phi, 16384, fs);
% A = fftdiff(PHI, fs);
% Z = ffts(z, nfft, fs);
% A = iffts(fftdiff(Z, fs, 2), 'symmetric', fs);
% nfft = 2^14;
% o = conv(RfMat, a.')./fs;
% p = conv(RfMat, A.')./fs;

end

