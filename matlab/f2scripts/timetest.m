
import tools.loadadv 
import beamform.batchbeamform

RfMat1 = loadadv('./data/icecfg1/timetest/rf_0001');
RfMat10 = repmat(RfMat, [1 1 10]);
RfMat10.meta.fileNumber = 2;
RfMat100 = repmat(RfMat, [1 1 100]);
RfMat100.meta.fileNumber = 3;

%%
tic;
batchbeamform(@beamform.deficecfg1, RfMat1, 1, 12, './data/icecfg1/timetest//');
t1 = toc

%%
tic;
batchbeamform(@beamform.deficecfg1, RfMat10, 1, 12, './data/icecfg1/timetest//');
t10 = toc

%%
tic;
batchbeamform(@beamform.deficecfg1, RfMat100, 1, 12, './data/icecfg1/timetest/');
t100 = toc