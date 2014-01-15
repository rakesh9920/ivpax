
import f2plus.batch_calc_multi
import tools.saveadv tools.loadadv tools.readjoblist tools.advdouble
import sigproc.bandpassdir
import beamform.batchbeamform beamform.sphericalmesh beamform.makejoblist
import imagevis.envelope;

PATH_MAIN = './data/icecfg1/psfgrid3/';
PATH_SCT = strcat(PATH_MAIN, 'sct/'); 
PATH_RFRAW = strcat(PATH_MAIN, 'rf/'); 
PATH_RFF = strcat(PATH_MAIN, 'rff/'); 
PATH_BF = strcat(PATH_MAIN, 'bf/'); 

if ~exist(PATH_SCT, 'dir'), mkdir(PATH_SCT), end
if ~exist(PATH_RFRAW, 'dir'), mkdir(PATH_RFRAW), end
if ~exist(PATH_RFF, 'dir'), mkdir(PATH_RFF), end
if ~exist(PATH_BF, 'dir'), mkdir(PATH_BF), end

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
saveadv(fullfile(PATH_SCT, 'sct_0001'), SctMat);

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
jobList = makejoblist(@batchbeamform, @beamform.deficecfg1, PATH_RFRAW, 12, PATH_BF);
job = readjoblist(jobList);

%submit(job{1});

%% plot psf
import tools.querydir

[FilePaths, nFiles] = querydir(PATH_BF, 'bf_0001_');

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
AngleWeight = @(x) 0.038952*abs(x) + 1; %0.038952
W = arrayfun(RangeWeight, Range).*arrayfun(AngleWeight, radtodeg(Angle));
D = 20.*log10((Env.*W)./max(max((Env.*W)))); 
D(D < -20) = -20;

%% mesh plot with 2D view
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



