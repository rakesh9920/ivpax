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

HTX1 = sfr(tx1, fldpts, f, 1500, S1);
HRX1 = sfr(rx1, fldpts, f, 1500, S2);
HRX2 = sfr(rx2, fldpts, f, 1500, S2);
HRX3 = sfr(rx3, fldpts, f, 1500, S2);
HRX4 = sfr(rx4, fldpts, f, 1500, S2);

figure;
plot(abs(HTX1), 'b'); hold on;
plot(abs(HRX1), 'r:');
plot(abs(HRX2), 'g:');
plot(abs(HRX3), 'c:');
plot(abs(HRX4), 'k:');
%% create pulse time signal and transfer function
opt.pulseType = 'gaussian';
opt.timeDelay = 0.04e-5;
opt.timeLength = 5.12e-5;
txsig = waveformgen(opt);
txsig(end) = [];
TXSIG = fft(txsig); % 2-sided DFT
TXSIG = 2.*TXSIG(1,1:1025).'; % convert to 1-sided

figure; plot(txsig);
figure; plot(abs(TXSIG));

%%
RX1SIG = (TXSIG.*HTX1.*HRX1);
test = [RX1SIG(1:end-1)./2; conj(RX1SIG(end))./2; conj(flipud(RX1SIG(2:(end-1))))./2];
plot(ifft(test,'symmetric'));

