% 1D circular piston model with 1tx, 4 rx 

%% meshing
[tx1 S1] = polarmesh([0 0.0011], [0 2*pi], 0.000025);
[rx1 S2] = polarmesh([0.0011 0.0013], [0 pi/2], 0.000025);
rx2 = polarmesh([0.0011 0.0013], [pi/2 pi], 0.000025);
rx3 = polarmesh([0.0011 0.0013], [pi 3*pi/2], 0.000025);
rx4 = polarmesh([0.0011 0.0013], [3*pi/2 2*pi], 0.000025);

figure;
plot3(tx1(1,:),tx1(2,:),tx1(3,:),'b.'); hold on;
plot3(rx1(1,:),rx1(2,:),rx1(3,:),'r.');
plot3(rx2(1,:),rx2(2,:),rx2(3,:),'g.');
plot3(rx3(1,:),rx3(2,:),rx3(3,:),'c.');
plot3(rx4(1,:),rx4(2,:),rx4(3,:),'k.');

%% calculate spatial frequency responses

[ft f] = qfft2(zeros(1,2048),40e6);
fldpts = [0; 0; 0.01];

htx1 = sfr(tx1, fldpts, f, 1500, S1);
hrx1 = sfr(rx1, fldpts, f, 1500, S2);
hrx2 = sfr(rx2, fldpts, f, 1500, S2);
hrx3 = sfr(rx3, fldpts, f, 1500, S2);
hrx4 = sfr(rx4, fldpts, f, 1500, S2);

% convert to 2-sided DFT
HTX1 = [htx1(1:(end-1))./2; conj(htx1(end))./2; conj(flipud(htx1(2:(end-1))))./2];
HRX1 = [hrx1(1:(end-1))./2; conj(hrx1(end))./2; conj(flipud(hrx1(2:(end-1))))./2];
HRX2 = [hrx2(1:(end-1))./2; conj(hrx2(end))./2; conj(flipud(hrx2(2:(end-1))))./2];
HRX3 = [hrx3(1:(end-1))./2; conj(hrx3(end))./2; conj(flipud(hrx3(2:(end-1))))./2];
HRX4 = [hrx4(1:(end-1))./2; conj(hrx4(end))./2; conj(flipud(hrx4(2:(end-1))))./2];

figure;
plot(fftshift(abs(HTX1)), 'b'); hold on;
plot(fftshift(abs(HRX1)), 'r:');
plot(fftshift(abs(HRX2)), 'g:');
plot(fftshift(abs(HRX3)), 'c:');
plot(fftshift(abs(HRX4)), 'k:');

%% create pulse time signal and transfer function

opt.pulseType = 'gaussian';
opt.timeDelay = 0.04e-5;
opt.timeLength = 5.12e-5;
txsig = waveformgen(opt);
txsig(end) = [];
TXSIG = fft(txsig).'; % 

figure; plot(txsig);
figure; plot(fftshift(abs(TXSIG)));
%% calculate piston impedance transfer function
zeta = 0.2;
omega_n = 2*pi*10e6;
c = 1500;
rhoH20 = 1000;
rhoSi3N4 = 3440;
t = 50e-6;
a = 120e-6;
E = 200e9;
v = 0.24;

f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];
omega = 2*pi.*f2s;
k = omega./c;

Rrad = rhoH20*c*pi*a^2.*(1 - besselj(1, 2.*k.*a)./(k.*a))./2;
Xrad = rhoH20*c*pi*a^2.*struveh1(2.*abs(k).*a)./(k.*a)./2;

meq = 1.84*pi*a^2*t*rhoSi3N4; 
D = E*t^3/(12*(1-v^2));
keq = 192*pi*D/a^2;

V2F =  (Rrad - 1i.*(Xrad) -1i.*keq./omega + 1i.*omega.*meq).';
%VF = ((2*zeta*omega_n + 1i.*(m.*omega - omega_n^2./omega)).^-1).';
F2V = V2F.^-1;
%FX = V2F.*(1i.*omega.');

%%
rho = 1000;
f2s = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];
RX1SIG = (TXSIG.*1i*2*pi*rho.*(f2s.').*HTX1.*HRX1.*F2V);
RTX1SIG = (TXSIG.*1i*2*pi*rho.*(f2s.').*HTX1.*HTX1.*F2V);
figure; plot(ifft(RX1SIG,'symmetric'));
figure; plot(ifft(RTX1SIG,'symmetric'));


