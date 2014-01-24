%%

import f2plus.batch_calc_multi tools.advdouble

DIR_MAIN = './data/bsc/fieldii';
DIR_SCT = [DIR_MAIN 'sct/'];
DIR_RF = [DIR_MAIN 'rf/'];

PATH_CFG = fullfile(DIR_MAIN, 'focused_piston');

%% create target field
for i = 1:100
    Dim = [0.02 0.02 0.02];
    Org = [0 0 0.012];
    targetDensity = 5; % in 1/mm^3
    bsc = 1;
    SIGMA = 0.316;
    
    nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity.*1000^3);
    
    TargetPos = bsxfun(@plus, bsxfun(@minus, [rand(nTargets,1).*Dim(1) rand(nTargets,1).*Dim(2) ...
        rand(nTargets,1).*Dim(3)], Dim./2), Org);
    
    Amp = ones(nTargets, 1).*sqrt(2*pi*bsc/targetDensity/SIGMA);
    
    SctMat = advdouble([TargetPos Amp], {'target','info'});
    SctMat.meta.numberOfTargets = nTargets;
    SctMat.meta.fileNumber = 1;
    
    %% run fieldii for target field
    
    TargetRf = batch_calc_multi(PATH_CFG, SctMat, DIR_RF);
    nPad = round(TargetRf.meta.startTime*TargetRf.meta.sampleFrequency);
    TargetRf = padarray(TargetRf, nPad, 'pre');
    TargetRf.meta.startTime = 0;
    
    %% run fieldii for single target
    
    SingleRf = batch_calc_multi(PATH_CFG, advdouble([0 0 0.01 sqrt(1/SIGMA)]), DIR_RF);
    nPad = round(SingleRf.meta.startTime*SingleRf.meta.sampleFrequency);
    SingleRf = padarray(SingleRf, nPad, 'pre');
    SingleRf = padarray(SingleRf, size(TargetRf,1), 'post');
    SingleRf.meta.startTime = 0;
    
    %%
    
    focus = 0.01;
    A = pi*0.005^2;
    
    focusTime = focus*2/1540;
    gateLength = 15*1540/5e6;
    gateDuration = gateLength*2/1540;
    gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*100e6);
    
    Sig1 = double(TargetRf(gate(1):gate(2)));
    Sig2 = double(SingleRf(gate(1):gate(2)));
    
    EstimatedBSC(i) = (sum(Sig1.^2)*A) / (sum(Sig2.^2)*0.46*(2*pi)^2*focus^2*gateLength);
    
%     plot(Sig1);
%     hold on;
%     plot(Sig2,'r');
    
end





















%%