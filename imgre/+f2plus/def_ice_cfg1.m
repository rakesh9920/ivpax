function [Prms, TxArray, RxArray] = def_ice_cfg1()
% Field II environment and transducer definition for transmit/receive
% circular baffled piston.

import fieldii.set_field
import fieldii.xdc_impulse
import fieldii.xdc_excitation
import fieldii.xdc_focus_times
import fieldii.xdc_free
import f2plus.xdc_nphys

% Set Field II parameters

Prms.rho = 1000; % kg/m^3
Prms.c = 1540;
Prms.fs = 100e6;
Prms.f0 = 5e6;
Prms.att = 0; % 176 % in dB/m
Prms.freq_att = 0;
Prms.att_f0 = 5e6;

set_field('c', Prms.c);
set_field('fs', Prms.fs);
set_field('att', Prms.att);
set_field('freq_att', Prms.freq_att);
set_field('att_f0', Prms.att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
Prms.impulse_response = impulse_response.*(hanning(length(impulse_response)).');
Prms.excitation = 1.*sin(2*pi*f0*(0:1/fs:5/f0));

% Define circular piston for transmit and receive

impScale = 1;
excScale = 1;

TxArray = apr_ice_cfg1();
xdc_impulse(TxArray, impScale.*impulse_response);
xdc_excitation(TxArray, excScale.*excitation);
xdc_focus_times(TxArray, 0, zeros(1, xdc_nphys(TxArray)));

RxArray = apr_ice_rx;
xdc_impulse(RxArray, impScale.*impulse_response);
xdc_excitation(RxArray, excScale.*excitation);
xdc_focus_times(RxArray, 0, zeros(1, xdc_nphys(RxArray)));

