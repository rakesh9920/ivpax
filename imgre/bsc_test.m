import fieldii.*
import f2plus.*
import tools.*
addpath ./bin/

% run Field II
field_init(-1);

% Set Field II parameters

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 5e6;
att = 0; % 176 % in dB/m
freq_att = 0;
att_f0 = 5e6;

set_field('c', c);
set_field('fs', fs);
set_field('att', att);
set_field('freq_att', freq_att);
set_field('att_f0', att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:5/f0));

% Define circular piston for transmit and receive

radius1 = 5/1000;
elementSize = 0.05/1000;
impScale = 1;
excScale = 1;

TxArray = xdc_piston(radius1, elementSize);
xdc_impulse(TxArray, impScale.*impulse_response);
xdc_excitation(TxArray, excScale.*excitation);
xdc_focus_times(TxArray, 0, zeros(1, xdc_nphys(TxArray)));

ns = 5; % scatterers per mm^3
Dim = [0.01 0.01 0.003];
BSC = 0.000001; % in 1/(m*sr)
sigma = 0.316798267931919;
Ns = round(ns*(Dim(1)*Dim(2)*Dim(3))*1000^3);
R = 0.5;
rxDepth = 1;
nIter = 50;

nSample = ceil(rxDepth/c*2*fs);
vscat2 = zeros(nIter, nSample);

[vscat1, t1] = calc_scat(TxArray, TxArray, [0 0 R], 2*sqrt(2*BSC/sigma/(ns*1000^3)));
vscat1 = vscat1.';

for i = 1:nIter
    PosX = rand(Ns,1).*Dim(1);
    PosY = rand(Ns,1).*Dim(2);
    PosZ = rand(Ns,1).*Dim(3);
    
    Pos = bsxfun(@plus, [PosX PosY PosZ], [-Dim(1)/2 -Dim(2)/2 (R - Dim(3)/2)]);
    Amp = ones(Ns,1).*2*sqrt(2*BSC/sigma/(ns*1000^3));
    
    [scat, t2] = calc_scat(TxArray, TxArray, Pos, Amp);
    scat = padarray(scat.', [0 round(t2*fs)], 'pre');
    scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');
    
    vscat2(i,:) = scat;
end

p1m = max(abs(calc_hp(TxArray, [0 0 1])));

field_end
%%
pscat1 = deconvwnr(vscat1, impulse_response).*fs/(pi*radius1^2);
pscat2 = deconvwnr(vscat2, impulse_response).*fs/(pi*radius1^2);
p2ed = abs(hilbert(pscat2));
pmean = mean(p2ed, 1);

Rr = (1:129871)./2./fs.*c;
Wtx = p1m^2/(2*rho*c)*4*pi;
Ii = Wtx./(4*pi*Rr.^2);

Wr = (p2ed.^2./(2*rho*c).*4*pi).*repmat(Rr, nIter, 1);
sigmar = Wr./repmat(Ii, nIter, 1);
sigmarwin = sigmar(:,64900:65200);
sigmarmean = mean(sigmarwin(:));

N = sigmarmean*2/pi/(Amp(1)^2*sigma);
Vres = sigmarmean*2/pi/(Amp(1)^2*sigma)/(ns*1000^3);

figure; hist(sqrt(sigmarwin(:)),40);
figure; probplot('rayleigh',sqrt(sigmarwin(:)));
% figure; probplot('exponential',sigmarwin(:));

% BSCm = sigmarmean/(4*pi*Vres)
