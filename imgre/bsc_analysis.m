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

f0 = 5e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*10e6*(0:1/fs:1/10e6));

%% 10x10 transmit array
TxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, ...
    1, [0 0 300]);
xdc_impulse(TxArray, 1.023694488611560e12.*impulse_response);
xdc_excitation(TxArray, excitation);
xdc_focus_times(TxArray, 0, zeros(1,100));

%% 10x10 receive array 
RxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, ...
    1, [0 0 0.005]);
xdc_impulse(RxArray, 5.245934383229829e11.*impulse_response);
xdc_focus_times(TxArray, 0, zeros(1,100));

%% 10x10 receive array (small)
RxArray2 = xdc_2d_array(10, 10, 45e-6, 45e-6, 5e-6, 5e-6, ones(10,10), 1, ...
    1, [0 0 0.005]);
xdc_impulse(RxArray2, 1.*impulse_response); % 1.557136275444180e+10
xdc_focus_times(RxArray2, 0, zeros(1,100));
xdc_excitation(RxArray2, excitation);

RxScale = 8.733288113753747e-12;
d3db = 0.004; % -3dB length at 1cm
% xdc_convert(TxArray);
% xdc_convert(RxArray);

%% 40x40 plane transmit array (z displaced)
Array1 = xdc_2d_array(40, 40, 90e-6, 90e-6, 10e-6, 10e-6, ones(40,40), 1, ...
    1, [0 0 300]);
PhysInfo = xdc_get(Array1, 'rect');
xdc_free(Array1);
Rect = zeros(19,1600);
Centers = zeros(1600,3);
for el = 1:1600
    
    Rect(1,el) = el; % physical element no.
    % rectangle coords
    Rect(2:13,el) = PhysInfo(11:22,el) + repmat([0; 0; -0.10], 4, 1);
    Rect(14,el) = 1; % apodization
    Rect(15,el) = PhysInfo(3,el); % math element width
    Rect(16,el) = PhysInfo(4,el); % math element height
    % math element center
    Rect(17:19,el) = PhysInfo(8:10,el) + repmat([0; 0; -0.10], 1, 1);
    Centers(el,:) = Rect(17:19,el).';
end
PlaneArray2 = xdc_rectangles(Rect.', Centers, [0 0 300]);
xdc_impulse(PlaneArray2, 1.269692385603829e+12.*impulse_response);
xdc_excitation(PlaneArray2, excitation);
xdc_focus_times(PlaneArray2, 0, zeros(1, 1600));

%% 40x40 plane transmit array (origin centered)
PlaneArray = xdc_2d_array(40, 40, 90e-6, 90e-6, 10e-6, 10e-6, ones(40,40), 1, ...
    1, [0 0 300]);

xdc_impulse(PlaneArray, 1.*impulse_response); % 1.269692385603829e+12
xdc_excitation(PlaneArray, excitation);
xdc_focus_times(PlaneArray, 0, zeros(1, 1600));

%% simulate cube of randomly distributed scatterers

v = zeros(100, 200);
m = zeros(100,1);

N = 200;
Dim = [0.001 0.001 0.001];

for i = 1:100
    
    PosX = rand(N,1).*Dim(1);
    PosY = rand(N,1).*Dim(2);
    PosZ = rand(N,1).*Dim(3);
    
    Pos = bsxfun(@plus, [PosX PosY PosZ], [-Dim(1)/2 -Dim(2)/2 (0.005 - Dim(3)/2)]);
    
    Amp = ones(N,1).*2/sqrt(pi*Nres)*0.5;
    
    % simulate data
    
    rxDepth = 0.03;
    nSample = ceil(rxDepth/SOUND_SPEED*2*fs);
    
    [scat, t0] = calc_scat(TxArray, RxArray, Pos, Amp);
    
    scat = padarray(scat.', [0 round(t0*fs)], 'pre');
    scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');
    
    v(i,:) = scat(1,600:799);
end

b = abs(hilbert(v(:,60:140)));

Nres = 24.309839217819821;

%% make scattering wall

N = 51200;
Dim = [0.005 0.005];
[PosX, PosY, PosZ] = ndgrid(linspace(0, Dim(1), round(sqrt(N))), ...
    linspace(0, Dim(2), round(sqrt(N))), 0);
WallPos = bsxfun(@plus, [PosX(:) PosY(:) PosZ(:)], [-Dim(1)/2 -Dim(2)/2 0.01]);
WallAmp = ones(round(sqrt(N))^2, 1);

%% make backscatter field

ns = 50; % scatterers per mm^3
Dim = [0.005 0.005 0.005];
BSC = 10e-6; % in 1/(cm*sr)
Ns = round(ns*(Dim(1)*Dim(2)*Dim(3))*1000^3);
for i = 1:100
    PosX = rand(Ns,1).*Dim(1);
    PosY = rand(Ns,1).*Dim(2);
    PosZ = rand(Ns,1).*Dim(3);
    
    BSPos = bsxfun(@plus, [PosX PosY PosZ], [-Dim(1)/2 -Dim(2)/2 0.01]);
    BSAmp = ones(Ns,1).*sqrt(BSC./ns./10^3).*2074;
    
    [scat, t0] = calc_scat_multi(RxArray2, RxArray2, BSPos, BSAmp);
    scat = padarray(scat.', [0 round(t0*fs)], 'pre');
    scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');
    
    RfMatOut = scat;
    ps(i,:) = sum(RfMatOut);
end

sig = ps(1,:);

psh = abs(hilbert(ps(:,1400:1450)));
BSCm = mean(mean(psh.^2,2)./mean(pr.^2)*0.01^2/2/(d3db^2)/1540/(50*10e-9)/100);

%%

%[FieldX, FieldY, FieldZ] = ndgrid(-0.02:0.00025:0.02, 0, 0:0.00025:0.04);
%[FieldX, FieldY, FieldZ] = ndgrid(0, 0, 0:0.001:0.20);
[FieldX, FieldY, FieldZ] = ndgrid(-0.005:0.0001:0.005, 0, 0.005:0.0001:0.015);
FieldPos = [FieldX(:) FieldY(:) FieldZ(:)];

[hp, t0] = calc_hp(RxArray2, FieldPos);
                                                                                    
Pres = reshape(hp, [size(hp,1) size(FieldX)]);

for i = 1:size(Pres, 1)
    imagesc(FieldZ(:), FieldX(:), squeeze(Pres(i,:,:,:)),[-2e-12 2e-12]);
    pause(0.001);
end


%%
rxDepth = 0.10;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

[scat, t0] = calc_scat_multi(RxArray2, RxArray2, WallPos, WallAmp);
scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

RfMatIn = scat;
pr = sum(RfMatIn);

[scat, t0] = calc_scat_multi(RxArray2, RxArray2, BSPos, BSAmp);
scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

RfMatOut = scat;
ps = sum(RfMatOut);










