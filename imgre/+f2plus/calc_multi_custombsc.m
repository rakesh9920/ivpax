function [RfMat, startTime] = calc_multi_custombsc(Tx, Rx, Points, bsc, varargin)
%CALC_SCAT_MULTI_CUSTOM 

import fieldii.calc_scat_multi

Parser = inputParser();
Parser.KeepUnmatched = true;
Parser.addOptional('SoundSpeed', 1540);
Parser.addOptional('FluidDensity', 1000);
Parser.addOptional('Area', 1);
Parser.addOptional('TargetDensity', 10*1000^3);

Parser.parse(varargin{:});
Prms = Parser.Results;
SoundSpeed = Prms.SoundSpeed;
FluidDensity = Prms.FluidDensity;
Area = Prms.Area;
TargetDensity = Prms.TargetDensity;

nPoints = size(Points, 1);

phi = sqrt(bsc/TargetDensity);
amp = 2*pi*phi/(FluidDensity*SoundSpeed*Area);

[RfMat, startTime] = calc_scat_multi(Tx, Rx, Points, ones(nPoints, 1).*amp);


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

