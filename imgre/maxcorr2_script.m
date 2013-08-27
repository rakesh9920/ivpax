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
prms('interpolate') = 16;
prms('threshold') = 0;
% misc
prms('progress') = true;
prms('interleave') = 2;

FieldPos = [0; 0; 0.014];

deltaTime = 0.3125e-7; % in seconds
deltaSpace = round(deltaTime*SAMPLE_FREQUENCY)/SAMPLE_FREQUENCY*SOUND_SPEED/2;
window = 2*2.5e-7; % in seconds
nCompare = 201;
nWindowSample = round(window*SAMPLE_FREQUENCY);

%% RF filtering and conversion
daq2mat([], [], prms);

%% preprocessing (instantaneous estimate)
maxcorrpre2([], [], [], RxPos, FieldPos, nCompare, deltaTime, nWindowSample, prms);

%% velocity estimate (max correlation estimate)
[VelEst, BfAvg, XCMat] = maxcorrest([], nCompare, deltaSpace, prms);















