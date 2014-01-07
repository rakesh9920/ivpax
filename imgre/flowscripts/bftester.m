
import f2plus.batch_calc_multi

PATH_MAIN = './data/bftester';
PATH_SCT = strcat(PATH_MAIN, '/sct');
PATH_RFRAW = strcat(PATH_MAIN, '/rf');
PATH_RFF = strcat(PATH_MAIN, '/rff');
PATH_BF = strcat(PATH_MAIN, '/bf');

TargetMat = advdouble([0 0 0.03 1], {'target', 'info'});
TargetMat.meta.fileNumber = 1;
TargetMat.meta.startFrame = 1;
TargetMat.meta.endFrame = 1;
TargetMat.meta.numberOfTargets = 1;
saveadv(PATH_SCT, TargetMat);

% simulate rf data
batch_calc_multi(@tools.def_ice_cfg1, TargetMat, PATH_RFRAW);

% zero-pad rf data
RfMat = loadadv(strcat(PATH_RFRAW, '/rf_0001.mat'));
startTime = RfMat.meta.startTime;
sampleFreq = RfMat.meta.sampleFrequency;
RfMat = padarray(RfMat, [round(startTime*sampleFrequency) 0 0], 'pre');
RfMat.meta.startTime = 0;
saveadv(strcat(PATH_RFRAW, '/rf_0001.mat'), RfMat);

% filter rf data
bandpassdir(PATH_RFRAW, 1e6, 9e6, sampleFreq, PATH_RFF);

% beamform
batchbeamform(@beamform.deficecfg1, strcat(PATH_RFF, '/rf_0001.mat'), 1, 100, ...
    PATH_BF);