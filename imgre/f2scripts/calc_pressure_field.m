
import fieldii.calc_hp fieldii.field_init fieldii.field_end
import beamform.sphericalmesh
addpath ./bin/

DIR_MAIN = './data/icecfg1/defocus study/';
DIR_FIELDII = [DIR_MAIN 'fieldii/'];

PATH_F2CFG = fullfile(DIR_FIELDII, 'ice1_defocustx');

%% Set field points (full field)

r1 = 0.0035/sin(pi/4);
rvg = r1:0.0003:(0.055 + 0.0035);
tvg = pi/2;
pvg = -pi/4:(pi/(4^4)):pi/4;
org = [0 0 -0.0035];

FieldPos = sphericalmesh(rvg, tvg, pvg, org, 1, 1, 1);

%% Set field points (line)
global focus;
focus = 0;

r1 = 0.0035/sin(pi/4);
rvg = 0.00175*focus + 0.03;
tvg = pi/2;
pvg = -pi/4:(pi/(4^4)):pi/4;
org = [0 0 -0.00175*focus];

FieldPos = sphericalmesh(rvg, tvg, pvg, org, 1, 1, 1);

%% run fieldii

[cfgDir, cfgName] = fileparts(PATH_F2CFG);
addpath(cfgDir);
cfgHandle = str2func(cfgName);

field_init(-1);

[~, TxArray, ~, ~, ~] = cfgHandle();
[PresMat, startTime] = calc_hp(TxArray, FieldPos);

field_end;
nTimes = size(PresMat, 1);

%%

D = reshape(PresMat, nTimes, [], 129);
maxD = max(max(max(D)));
E = 20.*log10(abs(D)./maxD);
E(E < -40) = -40;

[val, idx] = max(E);
idx = idx + round(startTime*100e6);
% MaxPres = [MaxPres squeeze(max(abs(D)))];
% MaxPresDB = [MaxPresDB squeeze(val)];
MaxSample = [MaxSample squeeze(idx)];

%%

D = reshape(PresMat, nTimes, [], 129);
maxD = max(max(max(D)));
E = 20.*log10(abs(D)./maxD);
E(E < -40) = -40;

X = reshape(FieldPos(:,1), [], 129);
Y = reshape(FieldPos(:,2), [], 129);
Z = reshape(FieldPos(:,3), [], 129);

figure;
xlabel('x [m]');
ylabel('y [m]');
zlabel('z [m]');
shading flat

for t = 1:nTimes
    surf(X, Y, Z, squeeze(E(t,:,:)), 'EdgeColor', 'none');
    view([1 0 0]);
    caxis([-40 0]);
    %caxis([minD maxD]./2);
    %axis([-0.02 0.02 0 0.02 minD./2 maxD./2]);
    axis image;
    pause(0.01)
end



