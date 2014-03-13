import f2plus.batch_calc_multi_materials tools.loadadv

PATH_CFG = './data/bsc/fieldii/linear_array_384_20mhz';
PATH_SCT = './data/bsc/fieldii/sct/sct_0001';
DIR_RF = './data/bsc/fieldii/rf/miniphantom2_run2';

Prms.OutputDirectory = DIR_RF;

for line = 1
    
    Prms.ConfigInputs = {line};
    Prms.Filename = ['rf_0001_' sprintf('%0.4d', line)];

    Inputs = {PATH_CFG, PATH_SCT, Prms};
    batch(@batch_calc_multi_materials, 0, Inputs);
end

%%

RfData = zeros(7000, 256);
l = 1;
for line = 65:2:192
    
    filepath = fullfile(DIR_RF, ['rf_0001_', sprintf('%0.4d', line)]);
    RfMat = loadadv(filepath);
    sig = double(sum(RfMat, 2));
    startTime = RfMat.meta.StartTime;
%     nPad = round(startTime*RfMat.meta.SampleFrequency);
    nPad = find(sig > 2e-26, 1);
    sig(1:nPad) = [];
%     sig = padarray(sig, nPad, 'pre');
    sig = padarray(sig, 7000 - size(sig, 1), 'post');
    
    RfData(:,line) = sig;
    l = l + 1;
end

%%

import imagevis.imager

width = 256;
height = round(7000/100e6*1540/2/100e-6);
imager(RfData, 50, height, width);