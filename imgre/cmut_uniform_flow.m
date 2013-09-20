
import beamform.gfbeamform4
import fieldii.*
import f2plus.*

%%

global SOUND_SPEED SAMPLE_FREQUENCY
SOUND_SPEED = 1540;
SAMPLE_FREQUENCY = 40e6;

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
inDir = './data/sct/';

for frame = 0:9
    xdc_focus(CMUT, [0], [0 0 0.005]);
    
    filename = strcat(inDir, 'SCT', sprintf('%0.4d', frame),'.mat');
    load(filename);
    [scat, t0] = calc_scat_multi(CMUT, CMUT, Pos, Amp);
    
    % decimate
    RxSigMat = zeros(16, ceil(size(scat, 1)/2));
    for ch = 1:16
        RxSigMat(ch,:) = decimate(scat(:,ch).',2);
    end
    
    RxSigMat = [zeros(1, round(t0*SAMPLE_FREQUENCY)) RxSigMat];
        
    save(strcat(inDir, 'MAT', sprintf('%0.4d', frame), '.mat'), 'RxSigMat');
end


%%

TxPos = zeros(3, 256);
RxPos = zeros(3, 256);
for tx = 1:16
    front = 1 + (tx - 1)*16;
    back = front + 16 - 1;
    TxPos(:,front:back) = repmat(Centers(:,tx),1,16);
    RxPos(:,front:back) = Centers;
end

[X, Y, Z] = ndgrid(-0.005:0.00005:0.005, 0, 0:0.00005:0.02);
grd = [X(:) Y(:) Z(:)];

FieldPos = grd.';

prms = containers.Map();
prms('planetx') = false;
prms('progress') = true;

BfMat = gfbeamform4([zeros(256, round(t0*SAMPLE_FREQUENCY)) scat.'], TxPos, ...
    RxPos, FieldPos, 1, prms);

Psf = squeeze(reshape(BfMat, size(X)));
Psfdb = 20.*log10(envelope(Psf)./max(max(envelope(Psf))));