function [] = calc_scat_multi_bsc(Tx, Rx, Points)
%CALC_SCAT_MULTI_BSC

import fieldii.calc_scat_multi
import sigproc.*

Points = [0 0 0.03];
nPoints = size(Points, 1);

[RfMat, startTime] = calc_scat_multi(Tx, Rx, Points, ones(nPoints));

RfCell = num2cell(RfMat, 2);

c = 1540;
rho = 1000;
SR = pi*0.005^2;
ns = 20*1000^3;
fs = 100e6;
nfft = 2^14;


bsc = 1;

phi = sqrt(2/pi*bsc/ns);

z = zeros(1, nfft);
z(1000) = -2*pi*phi/c/rho/SR*fs;
Z = ffts(z, nfft, fs);

a = diff(z).*fs;
A = iffts(fftdiff(Z, fs, 2), 'symmetric', fs);

o = conv(RfMat, a.')./fs;
p = conv(RfMat, A.')./fs;
%out = cellfun(@(x) conv(x, a), RfCell, 'UniformOutput', false);

end

