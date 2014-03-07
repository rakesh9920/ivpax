
DIR_RAW = './data/bsc/fieldii/rf/custom1_run1';

MultiSigs1 = [];
for file = 1:12
    
   filename = fullfile(DIR_RAW, ['bsc_raw' num2str(file)]);
   load(filename);
   
   MultiSigs1 = [MultiSigs1 MultiSigs];
end

%%

import sigproc.* f2plus.*

PATH_FILE = './data/bsc/fieldii/rf/focused_piston_1000_full2/bsc_sim_data';
load(PATH_FILE);

%Sig2 = SingleSig;

%%

focus = Prms.Focus;
fs = Prms.SampleFrequency;
c = Prms.SoundSpeed;
fc = Prms.CenterFrequency;
SR = Prms.Area;

focusTime = focus*2/c;
gateLength = 15*c/fc;
gateDuration = gateLength*2/c;
gate = round((focusTime + [-gateDuration/2 gateDuration/2]).*fs) + 30;
nfft = 2^13;
deltaF = fs/nfft;
%Freq = (-NFFT/2-1:NFFT/2).*deltaF;
Freq = (-nfft/2:nfft/2-1).*deltaF;
F1 = round(3.5e6/deltaF) + nfft/2 + 1;
F2 = round(8.5e6/deltaF) + nfft/2 + 1;
F3 = round(6.5e6/deltaF) + nfft/2 + 1 - F1;
k = (Freq(F1:F2).*2*pi/1540).';

Sigs1 = MultiSigs1(gate(1):gate(2),:);
Sig2 = SingleSig(gate(1):gate(2));

Win = hanning(gate(2)-gate(1)+1);
WinSigs1 = bsxfun(@times, Sigs1, Win);
% Energy = sum(Sigs1.^2, 1);
% winEnergy = sum(Win.^2, 1);
energyCorrection = (gate(2)-gate(1)+1)./sum(Win.^2, 1);

WINSIGS1 = ffts(WinSigs1, nfft, fs);
SIG2 = ffts(Sig2, nfft, fs);
PSD1 = 2.*abs(WINSIGS1(F1:F2,:)).^2.*energyCorrection;
% PSD1 = bsxfun(@times, PSD1, energyCorrection);
PSD2 = 2.*abs(SIG2(F1:F2)).^2;

RAT = bsxfun(@rdivide, PSD1, PSD2./(k.^2));

% CAM
CAM = RAT.*SR ./ (0.46*(2*pi)^2*focus^2*gateLength);
mfe = sum(abs(mean(CAM,2) - Bsc(F1:F2).')*100/size(CAM,1))
%figure; hist(sqrt(CAM(:)),25);

Bsc = zeros(1, nfft);
Bsc(1:nfft/2+1) = linspace(10, 0, nfft/2+1);
Bsc(nfft/2+1:end) = Bsc(nfft/2:-1:1);

% CM
% r1 = focus - gateLength/2;
% r2 = focus + gateLength/2;
% DS = (integral(@dsfocused, r1, r2, 'ArrayValued', true)./gateLength).';
% 
% CM = bsxfun(@rdivide, RAT.*SR^2 ./ ((2*pi)^2*focus^4*gateLength), DS(F1:F2));
% plot(Freq(F1:F2), mean(CM,2));


%%

figure;
plot(Freq(F1:F2), mean(CAM, 2), 'b'); hold on;
plot(Freq(F1:F2), mean(CAM, 2) + 1.96/sqrt(size(CAM, 2)), 'r:');
plot(Freq(F1:F2), Bsc(F1:F2), 'g:');
plot(Freq(F1:F2), mean(CAM, 2) - 1.96/sqrt(size(CAM, 2)), 'r:');
axis([Freq(F1) Freq(F2) 0.5 1.5]);
legend('mean value','95% confidence interval','expected value');
xlabel('frequency [Hz]');
ylabel('backscattering coefficient [m^-1]');
title('backscattering coefficient measured with CAM/point reference, hanning window and 15\lambda gate length');

figure;
hist(sqrt(CAM(:)), 30);
xlabel('\eta^{1/2} [m^{-1/2}]');
ylabel('number of occurences');
title('histogram for the square root backscattering coefficient');

figure;
probplot('rayleigh', sqrt(CAM(:)));
