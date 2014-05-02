%%

import f2plus.batch_calc_multi tools.advdouble

DIR_MAIN = './data/bsc/fieldii';
DIR_SCT = [DIR_MAIN 'sct/'];
DIR_RF = [DIR_MAIN 'rf/'];

PATH_CFG = fullfile(DIR_MAIN, 'focused_piston');

%% create target field

for i = 1:20
    Dim = [0.004 0.004 0.004];
    Org = [0 0 0.03];
    targetDensity = 20; % in 1/mm^3
    bsc = 1;
    rho = 1000;
    fc = 5e6;
    A = pi*0.005^2;
    
    Sigma = (rho*A/(2*pi)^2)^2/fc^2;
    
    nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity.*1000^3);
    
    TargetPos = bsxfun(@plus, bsxfun(@minus, [rand(nTargets,1).*Dim(1) rand(nTargets,1).*Dim(2) ...
        rand(nTargets,1).*Dim(3)], Dim./2), Org);
    
    Amp = ones(nTargets, 1).*2*sqrt(2*bsc/targetDensity/Sigma);
    
    SctMat = advdouble([TargetPos Amp], {'target','info'});
    SctMat.meta.numberOfTargets = nTargets;
    SctMat.meta.fileNumber = 1;
    
    %% run fieldii for target field
    
    TargetRf = batch_calc_multi(PATH_CFG, SctMat, DIR_RF);
    nPad = round(TargetRf.meta.startTime*TargetRf.meta.sampleFrequency);
    TargetRf = padarray(TargetRf, nPad, 'pre');
    TargetRf.meta.startTime = 0;
    
    %% run fieldii for single target
    
    SingleRf = batch_calc_multi(PATH_CFG, advdouble([0 0 0.03 1/A]), DIR_RF);
    nPad = round(SingleRf.meta.startTime*SingleRf.meta.sampleFrequency);
    SingleRf = padarray(SingleRf, nPad, 'pre');
    SingleRf = padarray(SingleRf, size(TargetRf,1), 'post');
    SingleRf.meta.startTime = 0;
    
    %%
    
    focus = 0.03;
    fs = 100e6;
    
    focusTime = focus*2/1540;
    gateLength = 10*1540/5e6;
    gateDuration = gateLength*2/1540;
    gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*100e6);
    
    Sig1 = double(TargetRf(gate(1):gate(2)));
    Sig2 = double(SingleRf(gate(1):gate(2)));
    
    NFFT = 8196;
    deltaF = fs/NFFT;
    Freq = (-NFFT/2:NFFT/2-1).*deltaF;
    F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
    F2 = round(6.5e6/deltaF) + NFFT/2 + 1;
    
    SIG1 = ffts(Sig1, NFFT, fs);
    SIG2 = ffts(Sig2, NFFT, fs);
    PSD1 = 2.*abs(SIG1(F1:F2));
    PSD2 = 2.*abs(SIG2(F1:F2));

    BSC1(:,i) = PSD1*A ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);
    k = (Freq(F1:F2).*2*pi/1540).';
    BSC2(:,i) = PSD1.*k.^2*A ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);
    
end
