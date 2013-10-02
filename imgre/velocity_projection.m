import beamform.gfbeamform4
import fieldii.*
import f2plus.*
import tools.*
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

[CMUT, Centers1] = xdc_1d_cmut(16);
[DTX , Centers2] = xdc_1d_cmut(4);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(CMUT, impulse_response);
xdc_impulse(DTX, impulse_response);

xdc_excitation(CMUT, sin(2*pi*f0*(0:1/fs:1/f0)));
xdc_excitation(DTX, sin(2*pi*f0*(0:1/fs:1/f0)));

%%

xdc_focus_times(CMUT, 0, zeros(1,16));

defocus = [0; 0; -0.001];
delays = sqrt(sqdistance(defocus, Centers2))./SOUND_SPEED;
xdc_focus_times(DTX, 0, delays);

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


