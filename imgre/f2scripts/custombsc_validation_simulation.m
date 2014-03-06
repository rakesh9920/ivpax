function [] = custombsc_validation_simulation()

import f2plus.calc_multi_custombsc f2plus.sct_spherical f2plus.xdc_area
import f2plus.bsc2filt
import fieldii.field_init fieldii.field_end fieldii.xdc_free
addpath ./bin/

DIR_MAIN = './data/bsc/fieldii/';

PATH_CFG = fullfile(DIR_MAIN, 'focused_piston');

[filedir, filename] = fileparts(PATH_CFG);
addpath(filedir);
cfg = str2func(filename);

nInstances = 1;
targetDensity = 1.*1000^3; % in 1/mm^3
nfft = 2^13;
Bsc = zeros(1, nfft);
Bsc(1:nfft/2+1) = linspace(10, 0, nfft/2+1);
Bsc(nfft/2+1:end) = Bsc(nfft/2:-1:1);
% fc = 5e6;

pt = rand*60;
disp(sprintf('pausing for %0.0f seconds...', pt));
pause(pt);
rng('shuffle');

for inst = 1:nInstances
    
    rvg = [0.015 0.025];
    tvg = [0 2*pi];
    pvg = [0 pi/2];
    org = [0 0 0];
    TargetPos = sct_spherical(rvg, tvg, pvg, org, targetDensity);
    
    %     nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity);
    %     TargetPos = bsxfun(@plus, bsxfun(@minus, [rand(nTargets,1).*Dim(1) ...
    %         rand(nTargets,1).*Dim(2), rand(nTargets,1).*Dim(3)], Dim./2), Org);
    
    %%%%%%%%%%%%%%% Start Field II %%%%%%%%%%%%%%%%%
    field_init(-1);
    
    [Prms, Tx, Rx, ~, ~] = cfg();
    
    Prms.TargetDensity = targetDensity;
    Prms.Area = xdc_area(Rx);
    fs = Prms.SampleFrequency;
    
    Filt = bsc2filt(Bsc, Prms);
    
    [MultiRf, startTime] = calc_multi_custombsc(Tx, Rx, TargetPos, Filt, fs);
    nPad = round(startTime*Prms.SampleFrequency);
    MultiRf = padarray(MultiRf, nPad, 'pre');
    MultiRf = padarray(MultiRf, 1000, 'post');
    
    if inst == 1;
        
        %         bsc_one = pi/2*targetDensity; % from pressure equation
        %         bsc_one = 2/pi*targetDensity; % from intensity equation
        bsc_one = targetDensity; % from Chen et al.
        [SingleRf, startTime] = calc_multi_custombsc(Tx, Rx, [0 0 Prms.Focus], ...
            bsc2filt(ones(1, nfft).*bsc_one), fs);
        nPad = round(startTime*Prms.SampleFrequency);
        SingleRf = padarray(SingleRf, nPad, 'pre');
        SingleRf = padarray(SingleRf, 1000, 'post');
        
    end
    
    xdc_free(Tx);
    xdc_free(Rx);
    
    field_end;
    %%%%%%%%%%%%%%% End Field II %%%%%%%%%%%%%%%%%
    
%     focus = Prms.Focus;
%     fs = Prms.SampleFrequency;
%     c = Prms.SoundSpeed;
%     
%     focusTime = focus*2/c;
%     gateLength = 5*c/fc;
%     gateDuration = gateLength*2/c;
%     gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs) + 30;
%     
%     Sig1 = double(MultiRf(gate(1):gate(2)));
%     Sig2 = double(SingleRf(gate(1):gate(2)));
    
    MultiSigs(:,inst) = MultiRf;
    SingleSig = SingleRf;
end

save(tempname(pwd),'MultiSigs', 'SingleSig', 'Prms');

end
