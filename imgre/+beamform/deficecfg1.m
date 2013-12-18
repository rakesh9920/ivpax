function [TxPos, RxPos, FieldPos, Prms] = deficecfg1()
%DEFICECFG1 Summary of this function goes here

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED CENTER_FREQUENCY;
SOUND_SPEED = 1540;
PULSE_REPITITION_RATE = 2000;
SAMPLE_FREQUENCY = 100e6;
CENTER_FREQUENCY = 6e6;

% SET PARAMETERS
Prms = containers.Map();

% filtering
Prms('filter') = true;
Prms('bw') = 5.66e6;
Prms('fc') = 6e6;

% beamforming & preprocessing
Prms('bfmethod') = 'frequency';
Prms('planetx') = true;
Prms('recombine') = true;
Prms('resample') = 1;



end

