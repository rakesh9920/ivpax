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
prms('window') = 'hanning';
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
prms('range gate') = 64;


RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
[X, Z] = meshgrid(-0.005:0.001:0.005, 0.009:0.001:0.019);
FieldPos = [reshape(X, 1, []); zeros(1, numel(X)); reshape(Z, 1, [])];

%% RF filtering and conversion
daq2mat([], [], prms);
%% preprocessing (instantaneous estimate)
instpre([], [], [], RxPos, FieldPos, 401, prms);
%% velocity estimate (instantaneous estimate)
[VelEst, BfAvg] = instest([], prms);
%% preprocessing (max correlation estimate)
maxcorrpre([], [], [], RxPos, FieldPos, 41, 0.5e-5, 201, prms);
%% velocity estimate (max correlation estimate)
[VelEst, BfAvg, XCMat] = maxcorrest([], 41, 0.5e-5, prms);
%% preprocessing for multiple points (instantaneous estimate)
matf_files = uigetfile_n_dir();
for i = 1:size(FieldPos, 2)
    prms('filename') = sprintf('PRE_%0.4d', i);
    instpre(matf_files, './data/styro/instpre/', [], RxPos, FieldPos(:,i), 401, prms);
end
%% velocity estimate for multiple points (instantaneous estimate)
VEMat = zeros(size(FieldPos, 2), 1969);
for i = 1:size(FieldPos, 2)
    filename = strcat('./data/styro/instpre/', 'PRE_', sprintf('%0.4d', i));
    [VelEst, ~] = instest(filename, prms);
    VEMat(i, :) = VelEst;
end