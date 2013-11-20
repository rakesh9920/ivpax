% Field II definition script for circular baffled piston

import fieldii.set_field
import fieldii.xdc_piston
import fieldii.xdc_impulse
import fieldii.xdc_excitation
import fieldii.xdc_focus_times

% import fieldiia.set_field
% import fieldiia.xdc_piston
% import fieldiia.xdc_impulse
% import fieldiia.xdc_excitation
% import fieldiia.xdc_focus_times

import f2plus.xdc_nphys

% Set Field II parameters

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 10e6;
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
excitation = 1.*sin(2*pi*f0*(0:1/fs:1000/f0));

% Define circular piston for transmit and receive

radius = 5/1000;
elementSize = 0.05/1000;
impScale = 1;
excScale = 1;

TxArray = xdc_piston(radius, elementSize);

xdc_impulse(TxArray, impScale.*impulse_response);
xdc_excitation(TxArray, excScale.*excitation);
xdc_focus_times(TxArray, 0, zeros(1, xdc_nphys(TxArray)));

RxArray = TxArray;
