import tools.*
import ultrasonix.*
import flow.*

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED;
SOUND_SPEED = 1500;
PULSE_REPITITION_RATE = 2000;
SAMPLE_FREQUENCY = 40e6;

% SET PARAMETERS
prms = containers.Map();

% filtering
prms('filter') = true;
prms('bw') = 5.2e6;
prms('fc') = 6.6e6;

% beamforming & preprocessing
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('recombine') = true;
prms('resample') = 1;

% instantaneous phase estimate
prms('ensemble') = 1;
prms('range gate') = 64;
prms('averaging') = 1;
prms('interleave') = 0;
prms('window') = 'rectwin';

% misc
prms('progress') = true;

% DEFINE GEOMETRY
RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.014];

% SET OTHER PARAMETER
nWindowSample = 101;

% CALCULATE MISC. VALUES
windowTime = nWindowSample/SAMPLE_FREQUENCY/prms('resample')
windowSpace = windowTime*SOUND_SPEED/2

%% RF filtering and conversion
daq2mat([], [], prms);

%% preprocessing (instantaneous estimate)
instpre([], [], [], RxPos, FieldPos, nWindowSample, prms);

%% velocity estimate (instantaneous estimate)
[VelEst, ~] = instest([], prms);
