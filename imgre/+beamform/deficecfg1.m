function [FieldPos, Prms, nWinSample] = deficecfg1(section, nSection)
%DEFICECFG1 Beamformer definition script for CMUT ICE configuration 1.

import beamform.sphericalmesh
import f2plus.apr_ice_rx

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED CENTER_FREQUENCY;
SOUND_SPEED = 1540;
PULSE_REPITITION_RATE = 1000;
SAMPLE_FREQUENCY = 100e6;
CENTER_FREQUENCY = 6e6;

% SET PARAMETERS
Prms = containers.Map();

% beamforming & preprocessing
Prms('bfmethod') = 'frequency';
Prms('planetx') = false;

nWinSample = 201;

r1 = 0.0035/sin(pi/4);
%rvg = linspace(r1, 0.05 + r1, 50);
% rvg = linspace(0.0035 + 0.025, 0.0035 + 0.035, 100);
% tvg = linspace(0, pi - pi/100, 100);
% pvg = -pi/4:pi/(4^4)/2:pi/4;
rvg = r1:0.0001:(0.055 + 0.0035);
tvg = 0;
pvg = -pi/4:(pi/(4^4)/2):pi/4;
org = [0 0 -0.0035];

[X, Y, Z] = sphericalmesh(rvg, tvg, pvg, org, section, nSection, 3);

FieldPos = [X(:) Y(:) Z(:)];
end