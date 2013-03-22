% 1D circular piston model with 1tx, 4 rx 

%% meshing

[tx1 S1] = polarmesh([0 0.0011], [0 2*pi], 0.0000125);
[rx1 S2] = polarmesh([0.0011 0.0013], [0 pi/2], 0.0000125);
rx2 = polarmesh([0.0011 0.0013], [pi/2 pi], 0.0000125);
rx3 = polarmesh([0.0011 0.0013], [pi 3*pi/2], 0.0000125);
rx4 = polarmesh([0.0011 0.0013], [3*pi/2 2*pi], 0.0000125);

figure;
plot3(tx1(1,:),tx1(2,:),tx1(3,:),'b.'); hold on;
plot3(rx1(1,:),rx1(2,:),rx1(3,:),'r.');
plot3(rx2(1,:),rx2(2,:),rx2(3,:),'g.');
plot3(rx3(1,:),rx3(2,:),rx3(3,:),'c.');
plot3(rx4(1,:),rx4(2,:),rx4(3,:),'k.');

%% calculate spatial frequency responses

[ft f] = qfft2(zeros(1,2048),40e6);
fldpts = [zeros(1,60); zeros(1,60); linspace(0.025,0.035,60)];
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];

htx1 = sfr(tx1, fldpts, f, 1500, S1);
hrx1 = sfr(rx1, fldpts, f, 1500, S2);
hrx2 = sfr(rx2, fldpts, f, 1500, S2);
hrx3 = sfr(rx3, fldpts, f, 1500, S2);
hrx4 = sfr(rx4, fldpts, f, 1500, S2);

% convert to 2-sided DFT
HTX1 = [htx1(1:(end-1),:)./2; conj(htx1(end,:))./2; conj(flipud(htx1(2:(end-1),:)))./2];
HRX1 = [hrx1(1:(end-1),:)./2; conj(hrx1(end,:))./2; conj(flipud(hrx1(2:(end-1),:)))./2];
HRX2 = [hrx2(1:(end-1),:)./2; conj(hrx2(end,:))./2; conj(flipud(hrx2(2:(end-1),:)))./2];
HRX3 = [hrx3(1:(end-1),:)./2; conj(hrx3(end,:))./2; conj(flipud(hrx3(2:(end-1),:)))./2];
HRX4 = [hrx4(1:(end-1),:)./2; conj(hrx4(end,:))./2; conj(flipud(hrx4(2:(end-1),:)))./2];

figure;
plot(fftshift(f2s.*1e-6).', fftshift(abs(HTX1)), 'b'); hold on;
plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX1)), 'r:');
plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX2)), 'g:');
plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX3)), 'c:');
plot(fftshift(f2s.*1e-6).', fftshift(abs(HRX4)), 'k:');

%% create pulse time signal and pulse spectrum

opt.pulseType = 'gaussian';
opt.timeDelay = 0.04e-5;
opt.timeLength = 5.12e-5;
opt.fbw = 0.80;
txsig = waveformgen(opt);
txsig(end) = [];
TXSIG = fft(txsig).'; % 

figure; plot(txsig);
figure; plot(fftshift(abs(TXSIG)));

%% calculate receive signals

rhoH20 = 1000;
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];
%RX1SIG = (TXSIG.*1i*2*pi*rhoH20.*(f2s.').*HTX1.*HRX1.*F2V);
%RTX1SIG = (TXSIG.*(1i.*(omega.')).*1i*2*pi*rhoH20.*(f2s.').*HTX1.*HTX1.*F2X);
TXSIG2 = repmat(TXSIG,1,size(HTX1,2));
RX1SIG = (TXSIG2.*HTX1.*HRX1);
RX2SIG = (TXSIG2.*HTX1.*HRX2);
RX3SIG = (TXSIG2.*HTX1.*HRX3);
RX4SIG = (TXSIG2.*HTX1.*HRX4);
RTX1SIG = (TXSIG2.*HTX1.*HTX1);
%figure; plot(ifft(RX1SIG,'symmetric'));
%figure; plot(ifft(RTX1SIG,'symmetric'));
rx1sig = ifft(RX1SIG,'symmetric');
rx2sig = ifft(RX2SIG,'symmetric');
rx3sig = ifft(RX3SIG,'symmetric');
rx4sig = ifft(RX4SIG,'symmetric');
rtx1sig = ifft(RTX1SIG,'symmetric');

%% beamform receive signals

rxsignals = [shiftdim(rx1sig, -1); shiftdim(rx2sig, -1);...
    shiftdim(rx3sig, -1); shiftdim(rx4sig, -1)];

txpts = [0; 0; 0];

rxpts(:,1) = [0.0012*cos(pi/4); 0.0012*sin(pi/4); 0];
rxpts(:,2) = [0.0012*cos(3*pi/4); 0.0012*sin(3*pi/4); 0];
rxpts(:,3) = [0.0012*cos(5*pi/4); 0.0012*sin(5*pi/4); 0];
rxpts(:,4) = [0.0012*cos(7*pi/4); 0.0012*sin(7*pi/4); 0];

fldpts = [zeros(1,2049); zeros(1,2049); 0:1.875e-5:0.0384];

bfsig = qbeamform(rxsignals, txpts, rxpts, fldpts);

%% ++ GRAVEYARD ++ %%
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








