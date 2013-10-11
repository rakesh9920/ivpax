import beamform.gfbeamform4
import fieldii.*
import f2plus.*
import tools.*
addpath ./bin/

%% set field ii parameters and define apertures

global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
SOUND_SPEED = 1540;
SAMPLE_FREQUENCY = 100e6;
PULSE_REPITITION_RATE = 2000;

f0 = 10e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

[RxAperture, RxCenters] = xdc_ice_rx();
[TxAperture, TxCenters] = xdc_ice_tx1();

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(RxAperture, impulse_response);
xdc_impulse(TxAperture, impulse_response);

xdc_excitation(RxAperture, sin(2*pi*f0*(0:1/fs:1/f0)));
xdc_excitation(TxAperture, sin(2*pi*f0*(0:1/fs:1/f0)));

%% set aperture delays

xdc_focus_times(RxAperture, 0, zeros(1,192));

defocus = [0; 0; -0.0035];
delays = sqrt(sqdistance(defocus, TxCenters))./SOUND_SPEED;
xdc_focus_times(TxAperture, 0, delays);

%% simulate data for psf

rxDepth = 0.06;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

[scat, t0] = calc_scat_multi(TxAperture, RxAperture, [0 0 0.01], 1);

scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

RxSigMat = scat;

%[zeros(192, round(t0*fs)) scat.'];
%scat = [scat zeros(16, )];

%% calculate psf

%[X, Y, Z] = ndgrid(-0.02:0.0005:0.02, 0, 0.015:0.0005:0.04);
%[X, Y, Z] = ndgrid(0, -0.02:0.0005:0.02, 0.015:0.0005:0.04);
[X, Y, Z] = ndgrid(-0.02:0.0005:0.02, -0.02:0.0005:0.02, 0.011);
grd = [X(:) Y(:) Z(:)];

FieldPos = grd.';

TxPos = defocus;
RxPos = RxCenters;

prms = containers.Map();
prms('planetx') = false;
prms('progress') = true;

BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, 1, prms);

Psf = squeeze(reshape(BfMat, size(X)));
Psfdb = 20.*log10(envelope(Psf)./max(max(envelope(Psf))));

%%

rxDepth = 0.06;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

BfMat = zeros(nSample, 16, 10);

for frame = 1:10
    Pos = [0 0 0.04] + [0.025*(frame - 1)/PULSE_REPITITION_RATE 0 0.025*(frame - 1)/PULSE_REPITITION_RATE]
    Amp = 1;
    
    [scat, t0] = calc_scat_multi(DTX, CMUT, Pos, Amp);
    
    scat = [zeros(16, round(t0*fs)) scat.'];
    scat = [scat zeros(16, nSample - size(scat, 2))];
    
    BfMat(:,:, frame) = scat.';
end

%%

[X, Y, Z] = ndgrid(-0.02:0.00025:0.02, 0, 0:0.00025:0.04);
grd = [X(:) Y(:) Z(:)];

angles_range = zeros(size(grd, 1), 1);
vel_res_z = zeros(size(grd, 1), 1);
vel_res_x = zeros(size(grd, 1), 1);
for pt = 1:size(grd, 1)
    
    grdpt = grd(pt,:).';
    r_dist = bsxfun(@minus, grdpt, Centers1);
    angles = atan2(r_dist(3,:),r_dist(1,:));
    
    angles_range(pt) = max(rad2deg(angles)) - min(rad2deg(angles));
    
    vel_res_z(pt) = min(abs(SOUND_SPEED.*12.5e-9./sin(angles)));
    vel_res_x(pt) = min(abs(SOUND_SPEED.*12.5e-9./cos(angles)));
end

AngleRange = reshape(angles_range, size(X, 1), size(X, 2), size(X, 3));
vel_res_z = reshape(vel_res_z, size(X, 1), size(X, 2), size(X, 3));
vel_res_x = reshape(vel_res_x, size(X, 1), size(X, 2), size(X, 3));


%%

figure;
imagesc(Z(:), X(:), squeeze(AngleRange));
colorbar(); grid;
axis image; axis tight;
xlabel('depth [m]');
ylabel('lateral [m]');

figure;
imagesc(Z(:), X(:), squeeze(AngleRange),[10 45]);
colorbar(); grid;
axis image; axis tight;
xlabel('depth [m]');
ylabel('lateral [m]');

%%


