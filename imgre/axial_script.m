import tools.*
import ultrasonix.*
import flow.*

prms = containers.Map();
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('filter') = true;
prms('bw') = 5.2e6;
prms('fc') = 6.6e6;
prms('progress') = true;
prms('recombine') = true;
prms('averaging') = 16;
prms('nsum') = 16;
prms('interpolate') = 8;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.024];

%%
daq2mat([], [], prms);
%%
instpre([], [], [], RxPos, FieldPos, 801, prms);
%% preprocessing (max correlation estimate)
maxcorrpre([], [], [], RxPos, FieldPos, 21, 1e-5, 401, prms);
%% velocity estimate (max correlation estimate)
[VelEst, BfAvg, XCMat] = maxcorrest([], 21, 1e-5, prms);
%%
VelEst = instest([], prms);