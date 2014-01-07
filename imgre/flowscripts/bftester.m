
import f2plus.batch_calc_multi
import tools.saveadv tools.loadadv tools.bandpassdir
import beamform.batchbeamform
import imager.envelope;

PATH_MAIN = './data/bftester';
PATH_SCT = strcat(PATH_MAIN, '/sct'); mkdir(PATH_SCT);
PATH_RFRAW = strcat(PATH_MAIN, '/rf'); mkdir(PATH_RFRAW);
PATH_RFF = strcat(PATH_MAIN, '/rff'); mkdir(PATH_RFF);
PATH_BF = strcat(PATH_MAIN, '/bf'); mkdir(PATH_BF);

%% create target data
TargetMat = advdouble([0 0 0.03 1], {'target', 'info'});
TargetMat.meta.fileNumber = 1;
TargetMat.meta.startFrame = 1;
TargetMat.meta.endFrame = 1;
TargetMat.meta.numberOfTargets = 1;
saveadv(strcat(PATH_SCT, '/sct_0001.mat'), TargetMat);

%% simulate rf data
batch_calc_multi(@f2plus.def_ice_cfg1, TargetMat, PATH_RFRAW);

%% zero-pad rf data
RfMat = loadadv(strcat(PATH_RFRAW, '/rf_0001.mat'));
startTime = RfMat.meta.startTime;
sampleFreq = RfMat.meta.sampleFrequency;
RfMat = padarray(RfMat, [round(startTime*sampleFreq) 0 0], 'pre'); % + 227 - 51
RfMat.meta.startTime = 0;
saveadv(strcat(PATH_RFRAW, '/rf_0001.mat'), RfMat);

%% filter rf data
bandpassdir(PATH_RFRAW, 1e6, 9e6, sampleFreq, PATH_RFF);

%% beamform
batchbeamform(@beamform.deficecfg1, strcat(PATH_RFRAW, '/rf_0001.mat'), 1, 100, ...
    PATH_BF);

%% plot psf

BfMat = loadadv(PATH_BF);
FieldPos = BfMat.meta.fieldPosition;

EnvMat = envelope(BfMat, 1);

X = reshape(FieldPos(:,1), [50 129 []]);
Y = reshape(FieldPos(:,2), [50 129 []]);
Z = reshape(FieldPos(:,3), [50 129 []]);
C = reshape(EnvMat(152,1,:), [50 129 []]);
D = 20.*log10(C./max(max(C))); D(D < -20) = -20;

surf(X, Y, Z, D);
axis equal;
axis([-4 4 -4 4 0 5].*1e-2);



