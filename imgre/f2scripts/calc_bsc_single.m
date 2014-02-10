%%

import f2plus.batch_calc_multi tools.advdouble

DIR_MAIN = './data/bsc/fieldii/';
DIR_SCT = [DIR_MAIN 'sct/'];
DIR_RF = [DIR_MAIN 'rf/'];

PATH_CFG = fullfile(DIR_MAIN, 'focused_piston');

[dir, filename] = fileparts(PATH_CFG);
addpath(dir);
cfg = str2func(filename);

%% run pulse-echo in field ii

Pos = [0 0 0.03];
Amp = 1;

SingleRf = batch_calc_multi(PATH_CFG, advdouble([Pos Amp]), DIR_RF);
nPad = round(SingleRf.meta.startTime*SingleRf.meta.sampleFrequency);
SingleRf = padarray(SingleRf, nPad, 'pre');
SingleRf = padarray(SingleRf, 2*length(SingleRf), 'post');
SingleRf.meta.startTime = 0;

%% run field pressure and sir in field ii

field_init(-1);

[Prms, Tx, Rx, ~, ~] = cfg();

[Pressure, startTime] = calc_hp(Tx, Pos);
nPad = round(startTime*Prms.fs);
Pressure = padarray(Pressure, nPad, 'pre');
Pressure = padarray(Pressure, 2*length(Pressure), 'post');
[Sir, startTime] = calc_h(Tx, Pos);
nPad = round(startTime*Prms.fs);
Sir = padarray(Sir, nPad, 'pre');

xdc_free(Tx); 
xdc_free(Rx);

field_end;

%%

focus = 0.03;
radius = 0.005;
A = pi*radius^2;
impulse_response = Prms.impulse_response.';
excitation = Prms.excitation.';
fs = Prms.fs;
f0 = Prms.f0;
rho = Prms.rho;
c = Prms.c;

focusTime = focus*2/1540;
gateLength = 10*1540/f0;
gateDuration = gateLength*2/1540;
gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs);
gate2 = round((focusTime/2 + [-gateDuration/2 gateDuration/2]).*fs);

% time-domain signals
Vrx = double(SingleRf(gate(1):gate(2)));
Prx0 = rho*c.*cumtrapz(deconvwnr(Vrx, impulse_response).*fs)./fs;
Ptx0 = rho*c.*cumtrapz(conv(excitation, impulse_response)./fs./rho)./fs;
%Pi = Pressure([round(gate(1)/2):round(gate(2)/2)]);
Pi = Pressure(gate2(1):gate2(2));

NFFT = 8196;
deltaF = fs/NFFT;
%Freq = (0:(NFFT/2-1)).*deltaF;
Freq = (-NFFT/2:NFFT/2-1).*deltaF;
% F1 = round(3.5e6/deltaF) + 1;
% F2 = round(6.5e6/deltaF) + 1;
k = (Freq.*2*pi/1540).';
f = (0:NFFT-1).*2*pi*1i*fs/NFFT; % for derivative

% power spectra
% EXC = abs(fft(excitation, NFFT)./fs);
% EXC = sqrt(2).*EXC(1:NFFT/2);
% IMP = abs(fft(impulse_response, NFFT)./fs);
% IMP = sqrt(2).*IMP(1:NFFT/2);
% SIR = abs(fft(Sir, NFFT)./fs);
% SIR = sqrt(2).*SIR(1:(NFFT/2));
% DTX = k.*SIR;
% GP = (k.*radius^2/(2*focus)/fs*sqrt(2));
% PRX0 = abs(fft(Prx0, NFFT)./fs);
% PRX0 = sqrt(2).*PRX0(1:(NFFT/2));
% PTX0 = abs(fft(Ptx0, NFFT)./fs);
% PTX0 = sqrt(2).*PTX0(1:(NFFT/2));
% PI = abs(fft(Pi, NFFT)./fs);
% PI = sqrt(2).*PI(1:(NFFT/2));
EXC = fftshift(fft(excitation, NFFT)./fs);
IMP = fftshift(fft(impulse_response, NFFT)./fs);
SIR = fftshift(fft(Sir, NFFT)./fs).*fs; % NOT SURE why fs multiplication is needed
DTX = 1i.*k.*SIR;
GP = 1i.*k.*radius^2/(2*focus);
PRX0 = fft(Prx0, NFFT);
PTX0 = fftshift(fft(Ptx0, NFFT)./fs);
PI = fft(Pi, NFFT)./fs;


%BSC1 = Psd1(F1:F2)*A ./ (Psd2(F1:F2).*0.46*(2*pi)^2*focus^2*gateLength);

%%
NFFT = 2^14;
deltaF = 100e6/NFFT;
Freq = (0:(NFFT/2-1)).*deltaF;
IMP = abs(fft(impulse_response, NFFT)./fs).^2;
IMP = 2.*IMP(1:NFFT/2);
plot(Freq, IMP, 'b.-'); hold on;





















%%