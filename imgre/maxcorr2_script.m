import tools.*
import ultrasonix.*
import flow.*

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY;
PULSE_REPITITION_RATE = 2000;
SAMPLE_FREQUENCY = 40e6;

prms = containers.Map();
% beamforming & preprocessing
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('recombine') = true;
prms('averaging') = 16;
prms('window') = 'hanning';
% filtering
prms('filter') = true;
prms('bw') = 5.2e6;
prms('fc') = 6.6e6;
% instantaneous estimate
prms('nsum') = 16;
% maxcorr estimate
prms('interpolate') = 16;
prms('threshold') = 0;
% misc
prms('progress') = true;
% testing
prms('ensemble') = 16;
prms('range gate') = 64;

FieldPos = [0; 0; 0.02];

delta = 0.75e-7; % in seconds
window = 1.5e-6; % in seconds
nCompare = 3;
nWindowSample = round(window.*SAMPLE_FREQUENCY);

%% RF filtering and conversion
daq2mat([], [], prms);

%% preprocessing (instantaneous estimate)
maxcorrpre2([], [], [], RxPos, FieldPos, nCompare, 0.75e-6, nWindowSample, prms);

%% velocity estimate (max correlation estimate)
[VelEst, BfAvg, XCMat] = maxcorrest([], nPoint, nDeltaSample, prms);















