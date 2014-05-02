import f2plus.batch_calc_multi_materials tools.loadadv

PATH_CFG = './data/bsc/miniphantom2_run3/linear_array_128_5mhz';
PATH_SCT = './data/bsc/miniphantom2_run3/data/sct_0001';
DIR_RF = './data/bsc/miniphantom2_run3/data/';

Prms.OutputDirectory = DIR_RF;

for line = 1
    
    Prms.ConfigInputs = {line};
    Prms.Filename = ['rf_0001_' sprintf('%0.4d', line)];
    
    Inputs = {PATH_CFG, PATH_SCT, Prms};
    batch(@batch_calc_multi_materials, 0, Inputs);
end

%%

RfData = zeros(6000, 320);
% l = 1;
li = 65:2:287;
li(4) = [];
li(2) = [];
for line = li
    
    filepath = fullfile(DIR_RF, ['rf_0001_', sprintf('%0.4d', line)]);
    RfMat = loadadv(filepath);
    sig = double(sum(RfMat, 2));
    startTime = RfMat.meta.StartTime;
    nPad = round(startTime*RfMat.meta.SampleFrequency);
    % %     nPad = find(sig > 2e-26, 1);
    %     sig(1:nPad) = [];
    sig = padarray(sig, nPad, 'pre');
    sig = padarray(sig, 6000 - size(sig, 1), 'post');
    
    RfData(:,line) = sig;
    %     l = l + 1;
end

%%

import imagevis.imager

width = 320;
height = round(6000/100e6*1540/2/100e-6);
imager(RfData, 50, height, width);

%%
sctmat = loadadv(PATH_SCT);

figure; hold on;
plot3d(sctmat(sctmat(:,4)==1,:),'b.', 'MarkerSize',0.01);
plot3d(sctmat(sctmat(:,4)==2,:),'r.', 'MarkerSize',0.01);
plot3d(sctmat(sctmat(:,4)==3,:),'k.', 'MarkerSize',0.01);
axis equal
axis([-0.02 0.02 -0.01 0.01 -0.00 0.04]);
view([0 1 0]);
leg = legend('background', 'hyperechoic', 'hypoechoic','Location','NorthEast');
dots = get(leg, 'children');
set(dots([1 4 7]), 'MarkerSize', 20);
xlabel('X [m]');
zlabel('Z [m]');
title('Imaging phantom with 2 lesions');

%%

materials = sctmat.meta.Materials;
nfft = size(materials(1).Bsc, 2);
fs = 100e6;
deltaF = fs/nfft;
Freq = (-nfft/2:nfft/2-1).*deltaF;
F1 = round(3e6/deltaF) + nfft/2 + 1;
F2 = round(8e6/deltaF) + nfft/2 + 1;
figure; hold on;
plot(Freq(F1:F2), materials(1).Bsc(F1:F2));
plot(Freq(F1:F2), materials(2).Bsc(F1:F2), 'r');
plot(Freq(F1:F2), materials(3).Bsc(F1:F2), 'k');
axis([3e6 8e6 -5 64])
xlabel('Frequency [Hz]');
ylabel('Backscattering coefficient [m^{-1}sr^{-1}]');
legend('background', 'hyperechoic', 'hypoechoic');
title('Backscattering coefficient for imaging phantom');

%%
import tools.loadadv beamform.gtbeamform2

DIR_RF = './data/bsc/miniphantom2_run3/data/';
DIR_BF = './data/bsc/miniphantom2_run3/data/';

Prms.SoundSpeed = 1540;
Prms.SampleFrequency =100e6; 

[X, Y, Z] = ndgrid(-0.01:0.0001:0.01, 0, 0.01:0.0001:0.03);
FieldPos = [X(:) Y(:) Z(:)];


BfMat = zeros(size(X));
for transmit = 1:128
    tic;
    filepath = fullfile(DIR_RF, ['rf_0001_', sprintf('%0.4d', transmit)]);
    RfMat = loadadv(filepath);
    TxPos = RfMat.meta.TxPositions(transmit,:);
    RxPos = RfMat.meta.RxPositions;
    
    nPad = round(RfMat.meta.StartTime*RfMat.meta.SampleFrequency);
    RfMat = padarray(RfMat, [nPad 0], 'pre');
    
    BfMatTemp = gtbeamform2(double(RfMat), TxPos, RxPos, FieldPos, 1, Prms);
    BfMat = BfMat + reshape(BfMatTemp, size(X));
    fprintf('tx %0.1d: %0.4fs\n', transmit, toc);
end
















