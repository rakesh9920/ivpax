function [Prms] = deficecfg1()
%DEFICECFG1 


% instantaneous phase estimate
Prms.ensemble = 1;
Prms.rangegate = 1;
Prms.averaging = 1;
Prms.resample = 1;
Prms.interleave = 0;
Prms.window = 'rectwin';
Prms.SOUND_SPEED = 1540;
Prms.SAMPLE_FREQUENCY = 100e6;
Prms.PULSE_REPITITION_RATE = 1000;
Prms.CENTER_FREQUENCY = 5e6;

end

