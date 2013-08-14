import tools.*
import ultrasonix.*
import flow.*

global PULSE_REPITITION_RATE
PULSE_REPITITION_RATE = 2000;

prms = containers.Map();
% beamforming & preprocessing
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('recombine') = true;
prms('averaging') = 16;
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
prms('range gate') = 128;


RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.01];

%% RF filtering and conversion
daq2mat([], [], prms);
%% preprocessing (instantaneous estimate)
instpre([], [], [], RxPos, FieldPos, 801, prms);
%% velocity estimate (instantaneous estimate)
[VelEst(5,:), BfAvg] = instest([], prms);
%% preprocessing (max correlation estimate)
maxcorrpre([], [], [], RxPos, FieldPos, 41, 0.5e-5, 201, prms);
%% velocity estimate (max correlation estimate)
[VelEst, BfAvg, XCMat] = maxcorrest([], 41, 0.5e-5, prms);
