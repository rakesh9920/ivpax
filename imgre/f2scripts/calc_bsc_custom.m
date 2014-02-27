%%

import f2plus.batch_calc_multi tools.advdouble f2plus.sct_spherical

DIR_MAIN = './data/bsc/fieldii/';
DIR_SCT = [DIR_MAIN 'sct/'];
DIR_RF = [DIR_MAIN 'rf/'];

PATH_CFG = fullfile(DIR_MAIN, 'focused_piston_mod');

[dir, filename] = fileparts(PATH_CFG);
addpath(dir);
cfg = str2func(filename);

%% create target field

for i = 1:1
    targetDensity = 20.*1000^3; % in 1/mm^3
    bsc = 1;
    rho = 1000;
    fc = 5e6;
    SR = pi*0.005^2;
    
    %     rvg = [0.017 0.023];
    %     tvg = [0 2*pi];
    %     pvg = [0 pi/2];
    %     org = [0 0 0];
    %     TargetPos = sct_spherical(rvg, tvg, pvg, org, targetDensity);
    
    Dim = [0.008 0.008 0.008];
    Org = [0 0 0.02];
    nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity);
    TargetPos = bsxfun(@plus, bsxfun(@minus, [rand(nTargets,1).*Dim(1) rand(nTargets,1).*Dim(2) ...
        rand(nTargets,1).*Dim(3)], Dim./2), Org);
    
    %%
    
    field_init(-1);
    
    [Prms, Tx, Rx, ~, ~] = cfg();
    
    Prms.ns = targetDensity;
    Prms.SR = SR;
    
    [MultiRf, startTime] = calc_scat_multi_bsc(Tx, Rx, TargetPos, bsc, Prms);
    nPad = round(startTime*Prms.fs);
    MultiRf = padarray(MultiRf, nPad, 'pre');
    MultiRf = padarray(MultiRf, 1000, 'post');
    
    %phi_mag = sqrt(2/pi*bsc/ns)
    
    if i == 1;
        
        %bsc_one = pi/2*targetDensity; % from pressure equation
        %bsc_one = 2/pi*targetDensity; % from intensity equation
        bsc_one = targetDensity; % from Chen et al.
        [SingleRf, startTime] = calc_scat_multi_bsc(Tx, Rx, [0 0 Prms.focus], bsc_one, Prms);
        nPad = round(startTime*Prms.fs);
        SingleRf = padarray(SingleRf, nPad, 'pre');
        SingleRf = padarray(SingleRf, 1000, 'post');
        
        %         [Pi, startTime] = calc_hp(Tx, [0 0 0.03]);
        %         nPad = round(startTime*Prms.fs);
        %         Pi = padarray(Pi, nPad, 'pre');
        %
        %         [Sir, startTime] = calc_h(Tx, [0 0 0.03]);
        %         nPad = round(startTime*Prms.fs);
        %         Sir = padarray(Sir, nPad, 'pre').*Prms.fs;
        
    end
    xdc_free(Tx); xdc_free(Rx); field_end;
    
    %%
    
    focus = Prms.focus;
    fs = Prms.fs;
    c = Prms.c;
    
    focusTime = focus*2/c;
    gateLength = 5*c/fc;
    gateDuration = gateLength*2/c;
    gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs) + 30;
    
    Sig1 = double(MultiRf(gate(1):gate(2)));%.*blackmanharris(gate(2)-gate(1)+1);
    Sig2 = double(SingleRf(gate(1):gate(2)));%.*blackmanharris(gate(2)-gate(1)+1);
    
    Sigs1(:,i) = Sig1;
    
    NFFT = 8196;
    deltaF = fs/NFFT;
    Freq = (-NFFT/2-1:NFFT/2).*deltaF;
    F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
    F2 = round(8.5e6/deltaF) + NFFT/2 + 1;
    
    SIG1 = ffts(Sig1, NFFT, fs);
    SIG2 = ffts(Sig2, NFFT, fs);
    
    PSD1 = 2.*abs(SIG1(F1:F2)).^2;
    PSD2 = 2.*abs(SIG2(F1:F2)).^2;
    
    BSC1(:,i) = PSD1*SR ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);
    k = (Freq(F1:F2).*2*pi/1540).';
    BSC2(:,i) = PSD1.*k.^2*SR ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);
    
end

%%

focus = 0.02;
fs = 100e6;
c = 1540;
fc = 5e6;
SR = pi*0.005^2;
focusTime = focus*2/c;
gateLength = 5*c/fc;
gateDuration = gateLength*2/c;
gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs) + 30;
NFFT = 8196;
deltaF = fs/NFFT;
Freq = (-NFFT/2-1:NFFT/2).*deltaF;
F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
F2 = round(8.5e6/deltaF) + NFFT/2 + 1;
F3 = round(6.5e6/deltaF) + NFFT/2 + 1 - F1;
k = (Freq(F1:F2).*2*pi/1540).';

Win = rectwin(gate(2)-gate(1)+1);
WinSigs1 = bsxfun(@times, Sigs1, Win);
% Energy = sum(Sigs1.^2, 1);
% winEnergy = sum(Win.^2, 1);
energyCorrection = (gate(2)-gate(1)+1)./sum(Win.^2, 1);

WINSIGS1 = ffts(WinSigs1, NFFT, fs);
SIG2 = ffts(Sig2, NFFT, fs);
PSD1 = 2.*abs(WINSIGS1(F1:F2,:)).^2.*energyCorrection;
% PSD1 = bsxfun(@times, PSD1, energyCorrection);
PSD2 = 2.*abs(SIG2(F1:F2)).^2;

RAT = bsxfun(@rdivide, PSD1, PSD2./(k.^2));
BSC = RAT.*SR ./ (0.46*(2*pi)^2*focus^2*gateLength);
B = BSC(1:F3,:);

figure;
plot(mean(BSC, 2));
axis([0 450 0 2])
figure;
hist(sqrt(BSC(:)), 30);
figure;
probplot('rayleigh', sqrt(BSC(:)));

