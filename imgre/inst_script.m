import tools.*
import ultrasonix.*
import flow.*

global PULSE_REPITITION_RATE SAMPLE_FREQUENCY SOUND_SPEED;
SOUND_SPEED = 1540;
PULSE_REPITITION_RATE = 2000;
SAMPLE_FREQUENCY = 50e6;

% SET PARAMETERS
prms = containers.Map();

% filtering
prms('filter') = true;
prms('bw') = 5.66e6;
prms('fc') = 6e6;

% beamforming & preprocessing
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('recombine') = true;
prms('resample') = 1;

% instantaneous phase estimate
prms('ensemble') = 1;
prms('range gate') = 1;
prms('averaging') = 1;
prms('interleave') = 0;
prms('window') = 'rectwin';

% misc
prms('progress') = true;
startPath = './data/sct3/';

% DEFINE GEOMETRY
%RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
RxPos = Centers;
%FieldPos = [zeros(1,101); zeros(1,101); 0:0.0001:0.01];
[X, Y, Z] = ndgrid(-0.01:0.0005:0.01, 0, 0:0.0005:0.01);
grd = [X(:) Y(:) Z(:)];
FieldPos = grd.';

% SET OTHER PARAMETER
nWindowSample = 61;

% CALCULATE MISC. VALUES
windowTime = nWindowSample/SAMPLE_FREQUENCY/prms('resample')
windowSpace = windowTime*SOUND_SPEED/2

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
instpre(MatFiles, [], [], RxPos, FieldPos, nWindowSample, prms);

%% velocity estimate (instantaneous estimate)
[VelEst, ~] = instest(PreFiles, prms);
