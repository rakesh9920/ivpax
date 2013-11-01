import beamform.gfbeamform4
import fieldii.*
import f2plus.*
import tools.*
addpath ./bin/

field_init(0);

%% set field ii parameters and define apertures

global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
SOUND_SPEED = 1540;
SAMPLE_FREQUENCY = 100e6;
PULSE_REPITITION_RATE = 2000;

f0 = 10e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:1/f0));

%% 10x10 transmit array

TxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, ...
    1, [0 0 300]);

Info = xdc_get(TxArray, 'rect');
TxCenters = Info(24:26,:);

xdc_impulse(TxArray, 1.023694488611560e12.*impulse_response);
xdc_excitation(TxArray, excitation);
xdc_focus_times(TxArray, 0, zeros(1,100));
%xdc_focus(TxArray, 0, [0 0 0.01]);

RxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, ...
    1, [0 0 300]);

Info = xdc_get(RxArray, 'rect');
RxCenters = Info(24:26,:);
xdc_impulse(RxArray, 1.023694488611560e12.*impulse_response);
xdc_excitation(RxArray, excitation);
xdc_focus_times(RxArray, 0, zeros(1,100));

%%

rxDepth = 0.03;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

[scat, t0] = calc_scat_multi(TxArray, RxArray, [0 0 0.001], 1);
scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

RxSigMat = scat;

%%
[X, Y, Z] = ndgrid(-0.005:0.0001:0.005, -0.005:0.0001:0.005, 0.0051);
%[X, Y, Z] = ndgrid(0, 0, 0:0.0001:0.02);
grd = [X(:) Y(:) Z(:)];

FieldPos = grd.';

TxPos = [];
RxPos = RxCenters;

prms = containers.Map();
prms('planetx') = true;
prms('progress') = true;

BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, 1, prms);

Psf = squeeze(reshape(BfMat, size(X)));
Psfdb = 20.*log10(envelope(Psf)./max(max(envelope(Psf))));


