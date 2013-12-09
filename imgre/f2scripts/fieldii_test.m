
import fieldii.*
import f2plus.*
addpath ./bin/

%% INITIALIZE FIELD II

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 10e6;
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
excitation = 1.*sin(2*pi*f0*(0:1/fs:1000/f0));

%% DEFINE CIRCULAR PISTON ARRAY

radius = 5/1000;
elementSize = 0.1/1000;
impScale = 1;
excScale = 1;

PistonTx = xdc_piston(radius, elementSize);

xdc_impulse(PistonTx, impScale.*impulse_response);
xdc_excitation(PistonTx, excScale.*excitation);
xdc_focus_times(PistonTx, 0, zeros(1, xdc_nphys(PistonTx)));

%%

[scat, t0] = calc_scat(PistonTx, PistonTx, [0 0 1], 1);
