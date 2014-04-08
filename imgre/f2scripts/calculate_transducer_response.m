import sigproc.* 

FILE_PATH = 'ice_cfg1_rx_response_impulse';

load(FILE_PATH);

%%

nfft = 2^13;
fs = 1e9;
deltaF = fs/nfft;
Freq = ((-nfft/2:nfft/2-1).*deltaF).';

Dis = 29/129.*mydisps(:,1) + 100/129.*mydisps(:,2);
Dis = Dis(4600:5600);
Dis = Dis - Dis(386);
Disf = lowpass(Dis, 1, 50e6, fs);

Exc = Vin(4600:5600,2);
Exc = Exc - Exc(386);
Excf = lowpass(Exc, 1, 50e6, fs);

Acc = gradient(gradient(Dis)).*fs.*fs;
Accf = lowpass(Acc, 1, 50e6, fs);

Imp = deconvwnr(Dis, Exc, 0.1).*fs;
Pmi = deconvwnr(Exc, Dis, 0.1).*fs;
Imp = lowpass(Imp, 1, 50e6, fs);
Pmi = lowpass(Pmi, 1, 50e6, fs);

ImpVA = deconvwnr(Acc, Exc, 0.1).*fs;
ImpAV = deconvwnr(Exc, Acc, 0.2).*fs;
ImpVA = lowpass(ImpVA, 1, 50e6, fs);
ImpAV = lowpass(ImpAV, 1, 50e6, fs);

IMPVA = ffts(ImpVA, nfft, fs);
IMPAV = ffts(ImpAV, nfft, fs);

ACCF = ffts(Accf, nfft, fs);
DISF = ffts(Disf, nfft, fs);
EXCF = ffts(Excf, nfft, fs);
IMP = ffts(Imp, nfft, fs);
PMI = ffts(Pmi, nfft, fs);

rx_impulse_response = resample(gradient(gradient(Pmi)).*fs.*fs, 1, 10);
rx_impulse_response = rx_impulse_response(45:94);
%%

figure; hold on;
plot(t(4600:5600), conv(Exc, Imp, 'same')./fs);
plot(t(4600:5600), Disf, 'r:');
legend('Calculated from convolution', 'Direct from model');
xlabel('Time [s]');
ylabel('Displacement [m]');
title('Mean membrane displacement calculated from deconvolution method');

figure; hold on;
plot(Freq, 20.*log10(abs(EXC.*IMP).^2));
plot(Freq, 20.*log10(abs(DISF).^2),'r:');
legend('Calculated from convolution', 'Direct from model');
xlabel('Frequency [Hz]');
ylabel('Power spectral density [W/Hz]');
title('Electromechanical transfer function calculated from two methods');

%%

Dis2 = 29/129.*mydisps(:,1) + 100/129.*mydisps(:,2);
Dis2 = Dis2(4600:5600);
Dis2 = Dis2 - Dis2(386);
Dis2f = lowpass(Dis2, 1, 50e6, fs);

DIS2F = ffts(Dis2f, nfft, fs);

figure; hold on;
plot(t(4600:5600), Imp);
plot(t(4600:5600), Dis2f.*fs,'r:');
legend('Deconvolution method', 'Impulse excitation method');
xlabel('Time [s]');
ylabel('Displacement/voltage [m/(V s)]');
title('Electromechanical impulse response calculated from two methods');

figure; hold on;
plot(Freq, 20.*log10(abs(IMP).^2));
plot(Freq, 20.*log10(abs(DIS2F.*fs).^2),'r:');
legend('Deconvolution method', 'Impulse excitation method');
xlabel('Frequency [Hz]');
ylabel('Power spectral density [W/Hz]');
title('Electromechanical transfer function calculated from two methods');


