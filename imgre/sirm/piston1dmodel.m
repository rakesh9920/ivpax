%1D circular piston model with 1tx, 4 rx

%% set parameters

global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE

SOUND_SPEED = 1500;
SAMPLE_FREQUENCY = 40e6;
PULSE_REPITITION_RATE = 60;

% define runtime flags
global VERBOSE

%% meshing

[tx1 S1] = polarmesh([0 0.0011], [0 2*pi], 0.0000125);
[rx1 S2] = polarmesh([0.0011 0.0013], [0 pi/2], 0.0000125);
rx2 = polarmesh([0.0011 0.0013], [pi/2 pi], 0.0000125);
rx3 = polarmesh([0.0011 0.0013], [pi 3*pi/2], 0.0000125);
rx4 = polarmesh([0.0011 0.0013], [3*pi/2 2*pi], 0.0000125);

if (exist('VERBOSE', 'var'))
    figure;
    plot3(tx1(1,:),tx1(2,:),tx1(3,:),'b.'); hold on;
    plot3(rx1(1,:),rx1(2,:),rx1(3,:),'r.');
    plot3(rx2(1,:),rx2(2,:),rx2(3,:),'g.');
    plot3(rx3(1,:),rx3(2,:),rx3(3,:),'c.');
    plot3(rx4(1,:),rx4(2,:),rx4(3,:),'k.');
end
%% define velocity field

icoords = [0; 0; 0.025];
speeds = [0; 0; 0.01];
vf = vfield(icoords, speeds, 60, 1);

clear icoords;
%% calculate spatial frequency responses

[~, f] = qfft2(zeros(1,2048),40e6);
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];

fldpts = reshape(vf, 3, []);

% calculate and convert to 2-sided
HTX1 = convert2sided(sfr(tx1, fldpts, f, 1500, S1), 1);
HRX1 = convert2sided(sfr(rx1, fldpts, f, 1500, S2), 1);
HRX2 = convert2sided(sfr(rx2, fldpts, f, 1500, S2), 1);
HRX3 = convert2sided(sfr(rx3, fldpts, f, 1500, S2), 1);
HRX4 = convert2sided(sfr(rx4, fldpts, f, 1500, S2), 1);

if (exist('VERBOSE', 'var'))
    figure;
    plot(fftshift(f2s.*1e-6).', fftshift(abs(HTX1)), 'b'); hold on;
    plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX1)), 'r:');
    plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX2)), 'g:');
    plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX3)), 'c:');
    plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX4)), 'k:');
end

clear ft f;
%% generate speckle field
[~, f] = qfft2(zeros(1,2048),40e6);
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];

[list, coords] = scattergen(1e-6, [1000 1000 1000], [0 0.4], [0 2*pi]);

xcoords = linspace(-0.010, 0.010, 1000);
ycoords = linspace(-0.010, 0.010, 1000);
zcoords = linspace(0, 0.03, 1000);
spos = [xcoords(coords(1,:)); ycoords(coords(2,:)); zcoords(coords(3,:))];

if (exist('VERBOSE', 'var'))
    figure;
    plot3(spos(1,:),spos(2,:),spos(3,:),'.');
end

HTX1SPECK = convert2sided(sfr(tx1, spos, f, 1500, S1), 1);
HRX1SPECK = convert2sided(sfr(rx1, spos, f, 1500, S2), 1);
HRX2SPECK = convert2sided(sfr(rx2, spos, f, 1500, S2), 1);
HRX3SPECK = convert2sided(sfr(rx3, spos, f, 1500, S2), 1);
HRX4SPECK = convert2sided(sfr(rx4, spos, f, 1500, S2), 1);

phase = angle(list);
amp = abs(list);
HSPECK = HTX1SPECK.*repmat(exp(-1i.*2.*pi.*phase).*amp.*0.025, size(HTX1SPECK, 1), 1);
%% create pulse time signal and pulse spectrum

opt.pulseType = 'gaussian';
opt.timeDelay = 0.22e-5;
opt.timeLength = 5.12e-5;
opt.fbw = 0.50;
opt.sampleFreq = 40e6;
opt.centerFreq = 1e6;
txsig = waveformgen(opt);
txsig(end) = [];
TXSIG = fft(txsig).'; %

if (exist('VERBOSE', 'var'))
    figure; plot(txsig);
    figure; plot(fftshift(abs(TXSIG)));
end

clear opt;

%% synthesize receive signals

% synthesize scatterer signals
[ft f] = qfft2(zeros(1,2048),40e6);
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];
%RX1SIG = (TXSIG.*1i*2*pi*rhoH20.*(f2s.').*HTX1.*HRX1.*F2V);
%RTX1SIG = (TXSIG.*(1i.*(omega.')).*1i*2*pi*rhoH20.*(f2s.').*HTX1.*HTX1.*F2X);
TXSIG2 = repmat(TXSIG,1,size(HTX1,2));
RX1SIG = (TXSIG2.*HTX1.*HRX1);
RX2SIG = (TXSIG2.*HTX1.*HRX2);
RX3SIG = (TXSIG2.*HTX1.*HRX3);
RX4SIG = (TXSIG2.*HTX1.*HRX4);
RTX1SIG = (TXSIG2.*HTX1.*HTX1);

rx1scatt = ifft(RX1SIG,'symmetric');
rx2scatt = ifft(RX2SIG,'symmetric');
rx3scatt = ifft(RX3SIG,'symmetric');
rx4scatt = ifft(RX4SIG,'symmetric');
rtx1scatt = ifft(RTX1SIG,'symmetric');

% synthesize speckle signals
TXSIG2 = repmat(TXSIG, 1, size(HTX1SPECK, 2));

rx1speck = ifft(sum(TXSIG2.*HSPECK.*HRX1SPECK, 2), 'symmetric');
rx2speck = ifft(sum(TXSIG2.*HSPECK.*HRX2SPECK, 2), 'symmetric');
rx3speck = ifft(sum(TXSIG2.*HSPECK.*HRX3SPECK, 2), 'symmetric');
rx4speck = ifft(sum(TXSIG2.*HSPECK.*HRX4SPECK, 2), 'symmetric'); 

% add
rx1sig = rx1scatt + repmat(rx1speck, 1, size(rx1scatt, 2));
rx2sig = rx2scatt + repmat(rx2speck, 1, size(rx2scatt, 2));
rx3sig = rx3scatt + repmat(rx3speck, 1, size(rx3scatt, 2));
rx4sig = rx4scatt + repmat(rx4speck, 1, size(rx4scatt, 2));
%% beamform receive signals

rxsignals = [shiftdim(rx1sig, -1); shiftdim(rx2sig, -1);...
    shiftdim(rx3sig, -1); shiftdim(rx4sig, -1)];

txpts = [0; 0; 0];

rxpts(:,1) = [0.0012*cos(pi/4); 0.0012*sin(pi/4); 0];
rxpts(:,2) = [0.0012*cos(3*pi/4); 0.0012*sin(3*pi/4); 0];
rxpts(:,3) = [0.0012*cos(5*pi/4); 0.0012*sin(5*pi/4); 0];
rxpts(:,4) = [0.0012*cos(7*pi/4); 0.0012*sin(7*pi/4); 0];

fldpts = [zeros(1,2049); zeros(1,2049); 0:1.875e-5:0.0384];
[xgrid ygrid zgrid] = meshgrid(linspace(-0.01, 0.01, 100), 0, linspace(0,0.0384, 2049));
%fldpts2 = [reshape(xgrid, 1, []); reshape(ygrid, 1, []); reshape(zgrid, 1, [])];
[bfsig bfmat] = gfbeamform(rxsignals, txpts, rxpts, fldpts);
%bfsig2 = qbeamform(rxsignals, txpts, rxpts, fldpts2);

if (exist('VERBOSE', 'var'))
    figure; plot(bfsig(1,:,1));
end

clear rxsignals rxpts;
%% short-time cross correlation velocity estimates

[dmat pos] = stdoppler(bfsig, 40, 20);
vmat = 1.875e-5*60.*diff(dmat,1,3);
loc = [zeros(2, length(pos)); (pos - 1).*1.875e-5];
%sf = samplefield(vf, speeds, loc, [0.001 0.001 3.75e-4]);
figure; imagesc(squeeze(vmat),[-0.02 0.02]);
%figure; imagesc(squeeze(sf(3,:,:)), [-0.02 0.02]);
%err = abs(vmat - sf(3,:,3:end));
%figure; imagesc(squeeze(err));
clear dmat pos;

%% instantaneous doppler velocity estimates

vsig = SOUND_SPEED/2/(2*pi*1e6).*instdoppler(bfsig);
plot(vsig);
%% full-time cross correlation velocity estimates

TxDist = sqrt(sqdistance(txpts, fldpts));
FtVel = ftdoppler(bfmat, TxDist, 20, 200);

%% ++ GRAVEYARD ++ %%
% nkern = 40;
% noverlap = 20;
% step = 46;
% 
% front = (step - 1)*(nkern - noverlap) + 1;
% back = front + nkern - 1;
% 
% figure; plot(squeeze(xcg(1,step,1,:))); title(strcat('cc', num2str(step)));
% figure; plot(hanning(nkern).'.*bfsig(1,front:back,1)); hold on;
% plot(hanning(nkern).'.*bfsig(1,front:back,2),'r');
% title(strcat('win bfsig', num2str(step)));

% calculate piston impedance transfer function
% zeta = 0.5;
% omega_n = 2*pi*10e6;
% c = 1500;
% rhoH20 = 1000;
% rhoSi3N4 = 3440;
% t = 50e-6;
% a = 0.0011;
% %a = 150e-6;
% E = 200e9;
% v = 0.24;
% f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];
% omega = 2*pi.*f2s;
% k = omega./c;
% Rrad = rhoH20*c*pi*a^2.*(1 - besselj(1, 2.*k.*a)./(k.*a))./2;
% Xrad = rhoH20*c*pi*a^2.*struveh1(2.*abs(k).*a)./(k.*a)./2;
% Rrad(1) = 0;
% Xrad(1) = 0;
% %meq = 1.84*pi*a^2*t*rhoSi3N4;
% D = E*t^3/(12*(1-v^2));
% %keq = 192*pi*D/a^2;
% keq = 5.9264e7;
% meq = 2.2371e-8;
% ceq = 2*sqrt(keq*meq)*zeta;
% a = 0.0011;
% %Rrad - 1i.*Xrad
% V2F =  (ceq -1i.*keq./omega + 1i.*omega.*meq).';
% V2F(1) = real(V2F(1));
% F2V = V2F.^-1;
% %X2F = (V2F.*(1i.*omega.'));
% X2F = (1i.*omega.*ceq + keq  - omega.^2.*meq).';
% F2X = X2F.^-1;
% plot(fftshift(f2s),fftshift(abs(F2X)));

% HTX1 = [htx1(1:(end-1),:)./2; conj(htx1(end,:))./2; conj(flipud(htx1(2:(end-1),:)))./2];
% HRX1 = [hrx1(1:(end-1),:)./2; conj(hrx1(end,:))./2; conj(flipud(hrx1(2:(end-1),:)))./2];
% HRX2 = [hrx2(1:(end-1),:)./2; conj(hrx2(end,:))./2; conj(flipud(hrx2(2:(end-1),:)))./2];
% HRX3 = [hrx3(1:(end-1),:)./2; conj(hrx3(end,:))./2; conj(flipud(hrx3(2:(end-1),:)))./2];
% HRX4 = [hrx4(1:(end-1),:)./2; conj(hrx4(end,:))./2; conj(flipud(hrx4(2:(end-1),:)))./2];






