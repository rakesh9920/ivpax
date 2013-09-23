
import beamform.gfbeamform4
import fieldii.*
import f2plus.*
addpath ./bin/

%%

global SOUND_SPEED SAMPLE_FREQUENCY
SOUND_SPEED = 1540;
SAMPLE_FREQUENCY = 50e6;

f0 = 6e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

[CMUT, Centers] = xdc_1d_cmut();

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(CMUT, impulse_response);

xdc_excitation(CMUT, sin(2*pi*f0*(0:1/fs:1/f0)));

%%
inDir = './data/sct3/';
outDir = './data/sct3/';

for frame = 0:9
    %xdc_focus(CMUT, [0; 170e-9], [0 0 0.01; 0 0 300]);
    %xdc_focus(CMUT, 0, [0 0 300]);
    xdc_focus_times(CMUT, 0, zeros(1,16));
    
    filename = strcat(inDir, 'SCT', sprintf('%0.4d', frame),'.mat');
    load(filename);
    [scat, t0] = calc_scat_multi(CMUT, CMUT, Pos, Amp);
    
    scat = [zeros(16, round(t0*fs)) scat.'];
    t(frame + 1) = t0;
    
    % decimate
    RxSigMat = zeros(16, ceil(size(scat, 2)/2));
    for ch = 1:16
        RxSigMat(ch,:) = decimate(scat(ch,:), 2);
    end
    
    %RxSigMat = [zeros(1, round(t0*SAMPLE_FREQUENCY)) RxSigMat];
        
    save(strcat(outDir, 'MAT', sprintf('%0.4d', frame), '.mat'), 'RxSigMat');
end

