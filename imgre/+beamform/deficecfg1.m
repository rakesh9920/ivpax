function [FieldPos, Prms, nWinSample] = deficecfg1(section, nSection)
%DEFICECFG1 Beamformer definition script for CMUT ICE configuration 1.

import beamform.sphericalmesh

Prms.planetx = false;
Prms.samplefrequency = 100e6;
Prms.centerfrequency = 5e6;
Prms.pulserepititionrate = 1000;
Prms.soundspeed = 1540;

nWinSample = 201;

r1 = 0.0035/sin(pi/4);
rvg = r1:0.0001:(0.055 + 0.0035);
tvg = pi/2;
pvg = -pi/4:(pi/(4^4)/2):pi/4;
org = [0 0 -0.0035];

FieldPos = sphericalmesh(rvg, tvg, pvg, org, section, nSection, 3);

end