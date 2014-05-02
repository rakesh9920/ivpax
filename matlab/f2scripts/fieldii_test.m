
import fieldii.*
import f2plus.*
addpath ./bin/

%% INITIALIZE FIELD II

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 5e6;
att = 0; % 176 % in dB/m
freq_att = 0;
att_f0 = 5e6;

field_init(-1);

set_field('c', c);
set_field('fs', fs);
set_field('att', att);
set_field('freq_att', freq_att);
set_field('att_f0', att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:2/f0));

%% DEFINE FOCUSED PISTON ARRAY

impScale = 1;
excScale = 1;
radius = 5/1000;
elementSize = 0.1/1000;
focus = 0.08;

TxArray = xdc_concave(radius, focus, elementSize);
xdc_impulse(TxArray, impScale.*impulse_response);
xdc_excitation(TxArray, excScale.*excitation);

%%

[Pressure, startTime] = calc_hp(TxArray, [0 0 focus]);
%nPad = round(startTime*100e6);
%Pressure = padarray(Pressure, nPad, 'pre');

[vs, startTime] = calc_scat(TxArray, TxArray, [0 0 focus], 1);
%nPad = round(startTime*100e6);
%SingleRf = padarray(SingleRf, nPad, 'pre');

xdc_free(TxArray);

%%

p0 = rho.*c.*(cumtrapz(conv(excitation, impulse_response)./fs./rho)./fs).';
ps = rho.*c.*(cumtrapz(deconvwnr(vs.', impulse_response).*fs)./fs).';

NFFT = 1024;
Freq = linspace(0, fs/2, NFFT/2 - 1);
k = (2*pi.*Freq./c).';

p0_psd = abs(fft(p0, NFFT)./fs).^2;
p0_psd = p0_psd(1:(NFFT/2-1)).*2;
pressure_psd = abs(fft(Pressure, NFFT)./fs).^2;
pressure_psd = pressure_psd(1:(NFFT/2-1)).*2;

deltaF = 100e6/NFFT;
F1 = round(3.5e6/deltaF);
F2 = round(6.5e6/deltaF);

figure;
plot(Freq(F1:F2), pressure_psd(F1:F2)./p0_psd(F1:F2));
hold on;
Gp = (k.*radius^2/(2*focus));
plot(Freq(F1:F2), Gp(F1:F2).^2, 'r.');

ps_psd = abs(fft(ps, NFFT)./fs).^2;
ps_psd = ps_psd(1:(NFFT/2-1)).*2;

figure;
numer = ps_psd(F1:F2);
% denom = pressure_psd(F1:F2).*Gp(F1:F2).^2.*(2*pi)^2./(pi*radius^2)^2./(k(F1:F2).^2);
denom = pressure_psd(F1:F2).*Gp(F1:F2).^2.*(2*pi)^2./(k(F1:F2).^2);
plot(Freq(F1:F2), numer./denom);

% numer = ps_psd;
% denom = pressure_psd.*Gp.^2.*(2*pi)^2./(pi*radius^2)^2./(k.^2);






