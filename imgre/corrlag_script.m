import tools.*
import ultrasonix.*
import flow.*

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED;
SOUND_SPEED = 1500;
PULSE_REPITITION_RATE = 2000;
SAMPLE_FREQUENCY = 40e6;

prms = containers.Map();

% beamforming & preprocessing
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('recombine') = true;
prms('averaging') = 16;
prms('window') = 'rectwin';

% filtering
prms('filter') = true;
prms('bw') = 5.2e6;
prms('fc') = 6.6e6;

% instantaneous estimate
prms('nsum') = 16;
prms('ensemble') = 16;
prms('range gate') = 64;

% maxcorr estimate
prms('interpolate') = 100;
prms('threshold') = 0;

% misc
prms('progress') = true;
prms('interleave') = 0;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.014];

nWindowSample = 101;

%% RF filtering and conversion
daq2mat([], [], prms);

%% preprocessing (instantaneous estimate)
instpre([], [], [], RxPos, FieldPos, nWindowSample, prms);

%% velocity estimate (instantaneous estimate)
[VelEst, BfAvg] = corrlagest([], prms);

