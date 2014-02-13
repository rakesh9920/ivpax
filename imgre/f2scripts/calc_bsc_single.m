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
Amp = 10;

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
Sir = padarray(Sir, nPad, 'pre').*Prms.fs;

xdc_free(Tx); 
xdc_free(Rx);

field_end;

%%

focus = 0.03;
radius = 0.005;
A = pi*radius^2;
impulse_response = Prms.impulse_response.';
Vtx = Prms.excitation.';
fs = Prms.fs;
f0 = Prms.f0;
rho = Prms.rho;
c = Prms.c;

focusTime = focus*2/1540;
gateLength = 10*1540/f0;
gateDuration = gateLength*2/1540;
gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs);
gate2 = round((focusTime/2 + [-gateDuration/2 gateDuration/2]).*fs);

% Vtx -> Imp -> (1) -> Ptx0 -> Dtx -> Tar -> -Sir/S -> Prx0 -> Imp -> Vrx
% VTX -> IMP -> (1) -> PTX0 -> DTX -> TAR -> (2) -> DRX -> PRX0 -> IMP -> VRX
% (1) = c * int(-)
% (2) = - 2pi * c/S * int(-)

% VTX -> IMP -> (1) -> PTX0 -> DTX -> TAR -> -SIR -> PRX -> IMP -> VRX

% time-domain signals
Vrx = double(SingleRf);
Pi = double(Pressure);
%Vrx = double(SingleRf(gate(1):gate(2)));
%Pi = Pressure(gate2(1):gate2(2));

Prx0 = rho*c.*cumtrapz(deconvwnr(Vrx, impulse_response).*fs)./fs;
Ptx0 = rho*c.*cumtrapz(conv(Vtx, impulse_response)./fs./rho)./fs;

NFFT = 8196;
deltaF = fs/NFFT;
%Freq = (0:(NFFT/2-1)).*deltaF;
Freq = (-NFFT/2:NFFT/2-1).*deltaF;
F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
F2 = round(6.5e6/deltaF) + NFFT/2 + 1;
k = (Freq.*2*pi/1540).';

% fourier-domain signals
VTX = ffts(Vtx, NFFT, fs);
IMP = ffts(impulse_response, NFFT, fs);
SIR = ffts(Sir, NFFT, fs);
DTX = fftdiff(SIR, fs)./c;
Dtx = iffts(DTX, 'symmetric', fs);
DRX = fftdiff(SIR, fs)./c;
GP = 1i.*k.*radius^2/(2*focus);
PRX0 = ffts(Prx0(gate(1):gate(2)), NFFT, fs);
PTX0 = ffts(Ptx0, NFFT, fs);
VRX = ffts(Vrx, NFFT, fs);
PI = ffts(Pi, NFFT, fs);

P = fftint(VTX.*IMP, fs)./rho.*rho.*c;
VR = P.*DTX.*SIR.*IMP;
PHI = -fftint(ones(NFFT,1), fs).*rho.*c.*A./(2*pi).*Amp;
PR1 = P.*DTX.*(-fftint(PHI, fs).*c.*2.*pi./A).*DRX;
%%
AMP(:,i) = VRX./(PI.*SIR.*IMP);
i = i + 1;
%plot(Freq(F1:F2), abs(A(F1:F2,:)).^2);
%%
t = transpose((0:NFFT-1).*1/fs);
d = PI.*Amp.*SIR.*IMP;
plot(t, iffts(d, 'symmetric', fs),'.');
hold on;
plot(t, Vrx(1:NFFT),'r:');


% PR3 = P.*DTX.*SIR;
% PR4 = P.*DTX.*(c.*fftint(ones(NFFT,1), fs)).*DRX;
% PR = P.*DTX.*(fftint(rho.*c.*fftint(PHI, fs), fs).*2.*pi.*c./A).*DRX;
% PR = P.*DTX.*fftint(PHI, fs).*c.*DRX;

