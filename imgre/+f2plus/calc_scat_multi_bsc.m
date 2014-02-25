function [RfMat, startTime] = calc_scat_multi_bsc(Tx, Rx, Points, bsc, Prms)
%CALC_SCAT_MULTI_BSC

import fieldii.calc_scat_multi
import sigproc.*

nPoints = size(Points, 1);

c = Prms.c;
rho = Prms.rho;
SR = Prms.SR;
ns = Prms.ns;
% fs = Prms.fs;

phi_mag = sqrt(2/pi*bsc/ns); % from pressure equation
%phi_mag = sqrt(pi/2*bsc/ns); % from intensity equation
amp = 2*pi*phi_mag/(rho*c*SR);

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

