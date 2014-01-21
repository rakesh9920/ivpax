
import fieldii.calc_hp fieldii.field_init fieldii.field_end
import beamform.sphericalmesh
addpath ./bin/

DIR_MAIN = './data/psf_grid_planetx/';
DIR_FIELDII = [DIR_MAIN 'fieldii/'];

PATH_F2CFG = fullfile(DIR_FIELDII, 'ice1_defocustx');

%% Set field points (full field)

r1 = 0.0035/sin(pi/4);
rvg = r1:0.0002:(0.055 + 0.0035);
tvg = 0;
pvg = -pi/4:(pi/(4^4)):pi/4;
org = [0 0 -0.0035];

FieldPos = sphericalmesh(rvg, tvg, pvg, org, 1, 1, 1);

%% Set field points (line)

r1 = 0.0035/sin(pi/4);
rvg = 0.00175*6 + 0.03;
tvg = 0;
pvg = -pi/4:(pi/(4^4)):pi/4;
org = [0 0 -0.00175*6];

FieldPos = sphericalmesh(rvg, tvg, pvg, org, 1, 1, 1);

%% run fieldii
[cfgDir, cfgName] = fileparts(PATH_F2CFG);
addpath(cfgDir);
cfgHandle = str2func(cfgName);

field_init(-1);

[~, TxArray, ~, ~, ~] = cfgHandle();
PresMat = calc_hp(TxArray, FieldPos);

field_end;
nTimes = size(PresMat, 1);

%%

D = reshape(PresMat, nTimes, [], 129);
maxD = max(max(max(D)));
E = 20.*log10(abs(D)./maxD);
E(E < -40) = -40;

[val, idx] = max(E);
MaxPres = [MaxPres squeeze(max(abs(D)))];
MaxPresDB = [MaxPresDB squeeze(val)];
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
colorbar;

for t = 1:nTimes
    surf(X, Y, Z, squeeze(E(t,:,:)), 'EdgeColor', 'none');
    view([0 -1 0]);
    caxis([-40 0]);
    %axis([-5 5 -5 5 0 6].*1e-2);
    axis image;
    pause(0.01)
end



