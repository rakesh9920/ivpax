
import f2plus.batch_calc_multi
import tools.saveadv tools.loadadv tools.readjoblist tools.advdouble tools.querydir
import sigproc.bandpassdir
import beamform.batchbeamform beamform.sphericalmesh beamform.makejoblist
import imagevis.envelope;

DIR_MAIN = './data/psf_grid_planetx/';
DIR_FIELDII = [DIR_MAIN 'fieldii/'];
DIR_BEAMFORMER = [DIR_MAIN 'beamformer/'];
DIR_SCT = [DIR_FIELDII, 'sct/']; 
DIR_RF = [DIR_FIELDII, 'rf/']; 
DIR_BF = [DIR_BEAMFORMER, 'bf/']; 

PATH_F2CFG = fullfile(DIR_FIELDII, 'ice1_planetx');
PATH_BFCFG = fullfile(DIR_BEAMFORMER, 'slice_hires');

if ~exist(DIR_SCT, 'dir'), mkdir(DIR_SCT), end
if ~exist(DIR_RF, 'dir'), mkdir(DIR_RF), end
if ~exist(DIR_BF, 'dir'), mkdir(DIR_BF), end

%% create target data

rvg = (0.01:0.01:0.05) + 0.0035;
tvg = 0;
pvg = degtorad(-40:20:40);
org = [0 0 -0.0035];
TargetPos = sphericalmesh(rvg, tvg, pvg, org, 1, 1, 1);
nTargets = size(TargetPos, 1);

SctMat = advdouble([TargetPos ones(nTargets, 1)], {'target', 'info'});
SctMat.meta.fileNumber = 1;
SctMat.meta.startFrame = 1;
SctMat.meta.endFrame = 1;
SctMat.meta.numberOfTargets = nTargets;
saveadv(fullfile(DIR_SCT, 'sct_0001'), SctMat);

%% simulate rf data

batch_calc_multi(PATH_F2CFG, SctMat, DIR_RF);

%% zero-pad rf data

RfMat = loadadv(fullfile(DIR_RF, 'rf_0001'));
startTime = RfMat.meta.startTime;
sampleFreq = RfMat.meta.sampleFrequency;
RfMat = padarray(RfMat, [round(startTime*sampleFreq) 0 0], 'pre'); %
RfMat.meta.startTime = 0;
saveadv(fullfile(DIR_RF, 'rf_0001'), RfMat);

%% beamform

jobList = makejoblist(@batchbeamform, PATH_BFCFG, DIR_RF, 12, DIR_BF);
job = readjoblist(jobList);

submit(job{1});

%% plot psf

[FilePaths, nFiles] = querydir(DIR_BF, 'bf_0001_');

BfMatCell = cellfun(@loadadv, FilePaths, 'UniformOutput', false);
FieldPosCell = cellfun(@(x) getfield(x, 'meta', 'fieldPosition'), ...
    BfMatCell, 'UniformOutput', false);

BfMat = cellfun(@double, BfMatCell, 'UniformOutput', false);
BfMat = cat(3, BfMat{:});
EnvMat = envelope(BfMat, 1);
FieldPos = cat(1, FieldPosCell{:});

X = reshape(FieldPos(:,1), [], 257, 1);
Y = reshape(FieldPos(:,2), [], 257, 1);
Z = reshape(FieldPos(:,3), [], 257, 1);
Range = sqrt(X.^2 + Y.^2 + Z.^2);
Angle = atan(X./Z);

Env = reshape(EnvMat(152,1,:), [], 257, 1);
RangeWeight = @(x) x^2;
AngleWeight = @(x) 1*abs(x) + 1; %0.038952
%W = 1;
W = arrayfun(RangeWeight, Range).*arrayfun(AngleWeight, radtodeg(Angle));
D = 20.*log10((Env.*W)./max(max((Env.*W)))); 
D(D < -60) = -60;

%% surf plot with 2D view

figure;
surf(X, Y, Z, D, 'EdgeColor', 'none');
view([0 -1 0]);
%axis([-5 5 -5 5 0 6].*1e-2);
shading interp
colorbar;
axis image;
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');

%%  contour plot

figure;
contour(X, Z, D);
axis([-4 4 0 6].*1e-2);
axis equal;



