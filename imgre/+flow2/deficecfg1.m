function [prms] = deficecfg1()
%DEFICECFG1 

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED CENTER_FREQUENCY;
SOUND_SPEED = 1540;
PULSE_REPITITION_RATE = 1000;
SAMPLE_FREQUENCY = 100e6;
CENTER_FREQUENCY = 5e6;

% SET PARAMETERS
prms = containers.Map();

% instantaneous phase estimate
prms('ensemble') = 1;
prms('range gate') = 1;
prms('averaging') = 1;
prms('resample') = 1;
prms('interleave') = 0;
prms('window') = 'rectwin';

end

