
import f2plus.batch_calc_multi
import tools.saveadv tools.loadadv tools.bandpassdir
import beamform.batchbeamform

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
RfMat = padarray(RfMat, [round(startTime*sampleFreq) 0 0], 'pre');
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