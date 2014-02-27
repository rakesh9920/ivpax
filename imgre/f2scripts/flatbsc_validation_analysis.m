
NFFT = 2^13;
deltaF = fs/NFFT;
Freq = (-NFFT/2-1:NFFT/2).*deltaF;
F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
F2 = round(8.5e6/deltaF) + NFFT/2 + 1;

SIG1 = ffts(Sig1, NFFT, fs);
SIG2 = ffts(Sig2, NFFT, fs);

PSD1 = 2.*abs(SIG1(F1:F2)).^2;
PSD2 = 2.*abs(SIG2(F1:F2)).^2;

BSC1(:,inst) = PSD1*SR ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);
k = (Freq(F1:F2).*2*pi/1540).';
BSC2(:,inst) = PSD1.*k.^2*SR ./ (PSD2.*0.46*(2*pi)^2*focus^2*gateLength);

focus = 0.02;
fs = 100e6;
c = 1540;
fc = 5e6;
SR = pi*0.005^2;
focusTime = focus*2/c;
gateLength = 5*c/fc;
gateDuration = gateLength*2/c;
gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs) + 30;
NFFT = 8196;
deltaF = fs/NFFT;
Freq = (-NFFT/2-1:NFFT/2).*deltaF;
F1 = round(3.5e6/deltaF) + NFFT/2 + 1;
F2 = round(8.5e6/deltaF) + NFFT/2 + 1;
F3 = round(6.5e6/deltaF) + NFFT/2 + 1 - F1;
k = (Freq(F1:F2).*2*pi/1540).';

Win = rectwin(gate(2)-gate(1)+1);
WinSigs1 = bsxfun(@times, Sigs1, Win);
% Energy = sum(Sigs1.^2, 1);
% winEnergy = sum(Win.^2, 1);
energyCorrection = (gate(2)-gate(1)+1)./sum(Win.^2, 1);

WINSIGS1 = ffts(WinSigs1, NFFT, fs);
SIG2 = ffts(Sig2, NFFT, fs);
PSD1 = 2.*abs(WINSIGS1(F1:F2,:)).^2.*energyCorrection;
% PSD1 = bsxfun(@times, PSD1, energyCorrection);
PSD2 = 2.*abs(SIG2(F1:F2)).^2;

RAT = bsxfun(@rdivide, PSD1, PSD2./(k.^2));
BSC = RAT.*SR ./ (0.46*(2*pi)^2*focus^2*gateLength);
B = BSC(1:F3,:);

figure;
plot(mean(BSC, 2));
axis([0 450 0 2])
figure;
hist(sqrt(BSC(:)), 30);
figure;
probplot('rayleigh', sqrt(BSC(:)));