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

% Array1 = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, 1, [0 0 300]);
% PhysInfo = xdc_get(Array1, 'rect');
% xdc_free(Array1);
% Rect = zeros(19,100);
% Centers = zeros(100,3);
% for el = 1:100
%
%     Rect(1,el) = el; % physical element no.
%     % rectangle coords
%     Rect(2:13,el) = PhysInfo(11:22,el) + repmat([0; 0; -0.005], 4, 1);
%     Rect(14,el) = 1; % apodization
%     Rect(15,el) = PhysInfo(3,el); % math element width
%     Rect(16,el) = PhysInfo(4,el); % math element height
%     % math element center
%     Rect(17:19,el) = PhysInfo(8:10,el) + repmat([0; 0; -0.005], 1, 1);
%     Centers(el,:) = Rect(17:19,el).';
% end
% TxArray = xdc_rectangles(Rect.', Centers, [0 0 300]);

TxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, 1, [0 0 300]);
RxArray = xdc_2d_array(10, 10, 90e-6, 90e-6, 10e-6, 10e-6, ones(10,10), 1, 1, [0 0 0.005]);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(TxArray, 1.023694488611560e12*impulse_response);
xdc_impulse(RxArray, 5.245934383229829e11.*impulse_response);

excitation = 4.*sin(2*pi*10e6*(0:1/fs:1/10e6));
xdc_excitation(TxArray, excitation);

xdc_focus_times(TxArray, 0, zeros(1,100));

% xdc_convert(TxArray);
% xdc_convert(RxArray);
%%
v = zeros(100, 200);
m = zeros(100,1);

N = 200;
Dim = [0.001 0.001 0.001];
%tic;

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
%toc
%%

rxDepth = 0.03;
nSample = ceil(rxDepth/SOUND_SPEED*2*fs);

[scat0, t0] = calc_scat(TxArray, RxArray, [0 0 0.005], 1);

scat0 = padarray(scat0.', [0 round(t0*fs)], 'pre');
scat0 = padarray(scat0, [0 nSample - size(scat0, 2)], 'post');

max(abs(scat0))







