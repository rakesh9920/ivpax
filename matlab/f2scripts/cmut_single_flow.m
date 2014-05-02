
import beamform.gfbeamform4
import fieldii.*
import f2plus.*
addpath ./bin/

%%

global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
SOUND_SPEED = 1540;
SAMPLE_FREQUENCY = 50e6;
PULSE_REPITITION_RATE = 2000;

f0 = 6e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

[CMUT, Centers] = xdc_1d_cmut(16);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(CMUT, impulse_response);

xdc_excitation(CMUT, sin(2*pi*f0*(0:1/fs:1/f0)));

%% SIMULATE RF DATA

inDir = './data/single2/';
outDir = './data/single2/';

Vel = [0 0 0.05];
% InitPos = [-0.005 0 0.005; 0.005 0 0.005];
% Amp = [1; 1];
InitPos = [0 0 0.01];
Amp = [1];
rxDepth = 0.04;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

xdc_focus_times(CMUT, 0, zeros(1,16));

for frame = 0:4
    
    Pos = bsxfun(@plus, InitPos, Vel./PULSE_REPITITION_RATE.*frame);
    
    [scat, t0] = calc_scat_multi(DTX, CMUT, Pos, Amp);
    
    scat = [zeros(16, round(t0*fs)) scat.'];
    scat = [scat zeros(16, nSample - size(scat, 2))];
    
    RxSigMat = zeros(16, ceil(size(scat, 2)/2));
    for ch = 1:16
        RxSigMat(ch,:) = decimate(scat(ch,:), 2);
    end
    
    save(strcat(outDir, 'MAT', sprintf('%0.4d', frame), '.mat'), 'RxSigMat');
end

%% ADD WGN

for f = 0:4
    filename = strcat('./data/single2/MAT', sprintf('%0.4d', f), '.mat');
    load(filename);
    RxSigMatN = tools.addwgn(2, RxSigMat, 12);
    filename = strcat('./data/single2/MATN', sprintf('%0.4d', f), '.mat'); 
    save(filename, 'RxSigMatN');
end


