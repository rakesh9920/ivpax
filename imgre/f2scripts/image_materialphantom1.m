import f2plus.batch_calc_multi_materials tools.loadadv

PATH_CFG = './data/bsc/fieldii/linear_array_20mhz';
PATH_SCT = './data/bsc/fieldii/sct/sct_0001';
DIR_RF = './data/bsc/fieldii/rf/miniphantom1_run1';

Prms.OutputDirectory = DIR_RF;

for line = 1
    
    Prms.ConfigInputs = {line};
    Prms.Filename = ['rf_0001_' sprintf('%0.4d', line)];
    
    Inputs = {PATH_CFG, PATH_SCT, Prms};
    batch(@batch_calc_multi_materials, 0, Inputs);
end

%%

RfData = zeros(6000, 128);
l = 1;
for line = 65:2:192
    
    filepath = fullfile(DIR_RF, ['rf_0001_', sprintf('%0.4d', line)]);
    RfMat = loadadv(filepath);
    sig = double(sum(RfMat, 2));
    nPad = round(RfMat.meta.StartTime*RfMat.meta.SampleFrequency);
    sig = padarray(sig, nPad, 'pre');
    sig = padarray(sig, 6000 - size(sig, 1), 'post');
    
    RfData(:,l) = sig;
    l = l + 1;
end

%%

import imagevis.imager

width = 64;
height = round(6000/100e6*1540/2/200e-6);
imager(RfData, 50, height, width);