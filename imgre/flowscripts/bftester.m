
import f2plus.batch_calc_multi
import tools.saveadv tools.loadadv 
import sigproc.bandpassdir
import beamform.batchbeamform
import imagevis.envelope;

PATH_MAIN = './data/bftester/';
PATH_SCT = strcat(PATH_MAIN, '/sct/'); mkdir(PATH_SCT);
PATH_RFRAW = strcat(PATH_MAIN, '/rf/'); mkdir(PATH_RFRAW);
PATH_RFF = strcat(PATH_MAIN, '/rff/'); mkdir(PATH_RFF);
PATH_BF = strcat(PATH_MAIN, '/bf/'); mkdir(PATH_BF);

%% create target data
SctMat = advdouble([0 0 0.03 1], {'target', 'info'});
SctMat.meta.fileNumber = 1;
SctMat.meta.startFrame = 1;
SctMat.meta.endFrame = 1;
SctMat.meta.numberOfTargets = 1;
saveadv(fullfile(PATH_SCT, 'sct_0001.mat'), SctMat);

%% simulate rf data
batch_calc_multi(@f2plus.def_ice_cfg1, SctMat, PATH_RFRAW);

%% zero-pad rf data
RfMat = loadadv(fullfile(PATH_RFRAW, 'rf_0001'));
startTime = RfMat.meta.startTime;
sampleFreq = RfMat.meta.sampleFrequency;
RfMat = padarray(RfMat, [round(startTime*sampleFreq) 0 0], 'pre'); % + 227 - 51
RfMat.meta.startTime = 0;
saveadv(fullfile(PATH_RFRAW, 'rf_0001'), RfMat);

%% filter rf data
bandpassdir(PATH_RFRAW, 1e6, 9e6, sampleFreq, PATH_RFF);

%% beamform
batchbeamform(@beamform.deficecfg1, fullfile(PATH_RFRAW, 'rf_0001'), 1, 100, ...
    PATH_BF);

%% plot psf
BfMat = loadadv(fullfile(PATH_MAIN, 'bf2'));
FieldPos = BfMat.meta.fieldPosition;

EnvMat = envelope(BfMat, 1);

X = reshape(FieldPos(:,1), [400 257 []]);
Y = reshape(FieldPos(:,2), [400 257 []]);
Z = reshape(FieldPos(:,3), [400 257 []]);
C = reshape(EnvMat(152,1,:), [400 257 []]);
D = 20.*log10(C./max(max(C))); D(D < -20) = -20;

%% mesh plot with 2D view
figure;
mesh(X, Y, Z, D);
view([0 1 0]);
axis([-0.5 0.5 -0.5 0.5 2.6 3.2].*1e-2);
axis equal;

%%  contour plot
figure;
contour(X, Z, D);
axis([-4 4 0 5].*1e-2);
axis equal;



