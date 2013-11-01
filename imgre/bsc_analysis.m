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
att = 176; % in dB/m
freq_att = 0;
att_f0 = 5e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);
set_field('att', att);
set_field('freq_att', freq_att);
set_field('att_f0', att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:1/f0));

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
d3db = 0.0051; % -3dB length at 1cm
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

%% scattering wall simulation

N = 51200;
Dim = [0.005 0.005];
R = 0.01;
rxDepth = 0.06;

[PosX, PosY, PosZ] = ndgrid(linspace(0, Dim(1), round(sqrt(N))), ...
    linspace(0, Dim(2), round(sqrt(N))), 0);
WallPos = bsxfun(@plus, [PosX(:) PosY(:) PosZ(:)], [-Dim(1)/2 -Dim(2)/2 R]);
WallAmp = ones(round(sqrt(N))^2, 1);

nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

[scat, t0] = calc_scat_multi(RxArray2, RxArray2, WallPos, WallAmp);
scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

PRef = sum(scat);
PRefED = abs(hilbert(PRef));

%% make backscatter field

ns = 10; % scatterers per mm^3
Dim = [0.006 0.006 0.003];
BSC = 1; % in 1/(cm*sr)
Ns = round(ns*(Dim(1)*Dim(2)*Dim(3))*1000^3);
R = 0.01;
rxDepth = 0.06;
nIter = 100;
tau = 1e-6;

nSample = ceil(rxDepth/SOUND_SPEED*2*fs);
PScat = zeros(nIter, nSample);

for i = 1:nIter
    PosX = rand(Ns,1).*Dim(1);
    PosY = rand(Ns,1).*Dim(2);
    PosZ = rand(Ns,1).*Dim(3);
    
    BSPos = bsxfun(@plus, [PosX PosY PosZ], [-Dim(1)/2 -Dim(2)/2 R]);
    %BSAmp = ones(Ns,1).*sqrt(BSC*100/(ns*1000^3)*1000*1540/(0.0005^2));
    BSAmp = ones(Ns,1).*sqrt(BSC*100/(ns*1000^3)/0.01^2);
    
    [scat, t0] = calc_scat_multi(RxArray2, RxArray2, BSPos, BSAmp);
    scat = padarray(scat.', [0 round(t0*fs)], 'pre');
    scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');
    
    PScat(i,:) = sum(scat);
end

PScatED = abs(hilbert(PScat.')).';
%%
nWinSample = 200; % in samples
nWinStart = 1500;
T = nWinSample*10e-9;
PS = PScatED(:,nWinStart:(nWinStart + nWinSample - 1));
PR = PRefED(1,1300:1500);
C1 = mean(mean(PS.^2,2)./mean(PR.^2));
C2 = R^2/(2*pi*(d3db/2)^2*SOUND_SPEED*T);
C3 = 2*tau*SOUND_SPEED*att/(exp(tau*SOUND_SPEED*att) - ...
    exp(-tau*SOUND_SPEED*att));
C4 = 2*SOUND_SPEED*att*T/(exp(SOUND_SPEED*att*T) - exp(-SOUND_SPEED*att*T));
C5 = exp(-SOUND_SPEED*att*T);

BSCm = mean(C1.*C2*C3*C4*C5/100) % in 1/(cm*sr)

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


%%

%[FieldX, FieldY, FieldZ] = ndgrid(-0.02:0.00025:0.02, 0, 0:0.00025:0.04);
%[FieldX, FieldY, FieldZ] = ndgrid(0, 0, 0:0.001:0.20);
[FieldX, FieldY, FieldZ] = ndgrid(-0.005:0.0001:0.005, 0, 0:0.0001:0.015);
%[FieldX, FieldY, FieldZ] = ndgrid(-0.005:0.0001:0.005, -0.005:0.0001:0.005, 0.01);
FieldPos = [FieldX(:) FieldY(:) FieldZ(:)];

[hp, t0] = calc_hp(TxArray, FieldPos);                                                                                     
Pres = reshape(hp, [size(hp,1) size(FieldX)]);

for i = 1:1:size(Pres, 1)
    %imagesc(0:0.0001:0.015, -0.005:0.0001:0.005, squeeze(Pres(i,:,:,:)),[-2 2]);
    surf(FieldZ,FieldX,squeeze(Pres(i,:,:,:)));
    set(gcf,'renderer','zbuffer')
    axis([0 0.015 -0.005 0.005 -10 10]); caxis([-2 2]);
    %axis equal; axis tight;
    title(num2str(i)); xlabel('z [m]'); ylabel('x [m]');
    drawnow; pause(0.001);
    writeVideo(vw, getframe);
end


%%

[scat, t0] = calc_scat_multi(RxArray2, RxArray2, BSPos, BSAmp);
scat = padarray(scat.', [0 round(t0*fs)], 'pre');
scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

RfMatOut = scat;

ps = sum(RfMatOut);

%%
ns = 50; % scatterers per mm^3
Dim = [0.005 0.005 0.010];
Ns = round(ns*(Dim(1)*Dim(2)*Dim(3))*1000^3);
R = 0.01;
rxDepth = 0.06;
nIter = 100;

nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

PD = zeros(nIter, nSample);

for i = 1:nIter
    
    PosX = rand(Ns,1).*Dim(1);
    PosY = rand(Ns,1).*Dim(2); 
    PosZ = rand(Ns,1).*Dim(3);
    
    BSPos = bsxfun(@plus, [PosX PosY PosZ], [-Dim(1)/2 -Dim(2)/2 R]);
    BSAmp = ones(Ns,1).*1;
    
    [scat, t0] = calc_scat(TxArray2, RxArray2, BSPos, BSAmp);
    scat = padarray(scat.', [0 round(t0*fs)], 'pre');
    scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');
    
    PD(i,:) = scat;
end








