import tools.*
import ultrasonix.*
import flow.*

% SET GLOBAL VARIABLES
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
prms('recombine') = false;
prms('resample') = 100;

% max correlation estimate
prms('threshold') = 0;
prms('interpolate') = 100;
prms('averaging') = 1;
prms('interleave') = 0;
prms('window') = 'rectwin';
prms('add wgn') = 20;

% misc
prms('progress') = true;
startPath = './data/styro/';

% DEFINE GEOMETRY
RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.014];

% SET OTHER PARAMETER
deltaSample = 10;
nWindowSample = 101*5*5;
nCompare = 55;

% CALCULATE MISC. VALUES
deltaTime = deltaSample/SAMPLE_FREQUENCY/prms('resample');
deltaSpace = deltaSample/SAMPLE_FREQUENCY/prms('resample')*SOUND_SPEED/2;

windowTime = nWindowSample/SAMPLE_FREQUENCY/prms('resample')
windowSpace = windowTime*SOUND_SPEED/2
velRes = deltaSpace*PULSE_REPITITION_RATE/(prms('interleave') + 1)
maxVel = nCompare/2*velRes

%% choose MAT/MATF file(s)
[filename pathname] = uigetfile('', '', startPath, 'MultiSelect', 'on');
if isa(filename, 'cell')
    MatFiles = cellstr(cat(2, repmat(pathname, numel(filename), 1), ...
        cat(1, filename{:})));
else
    MatFiles = cat(2, pathname, filename);
end
%% choose PRE file(s)
[filename pathname] = uigetfile('', '', startPath, 'MultiSelect', 'on');
if isa(filename, 'cell')
    PreFiles = cellstr(cat(2, repmat(pathname, numel(filename), 1), ...
        cat(1, filename{:})));
else
    PreFiles = cat(2, pathname, filename);
end
%% RF filtering and conversion
daq2mat([], [], prms);

%% preprocessing (instantaneous estimate)   
maxcorrpre2(MatFiles, [], [], RxPos, FieldPos, nCompare, deltaSample, ...
    nWindowSample, prms);

%% velocity estimate (max correlation estimate)
[VelEst, XCMat] = maxcorrest(PreFiles, nCompare, deltaSample, prms);
