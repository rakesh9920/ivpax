%%
filename = 'rfdata/unirad_ultrasonix2.rf'; % path to RF file
header = 'rfdata/unirad_ultrasonix2.bmh'; % path to BMH file

% Extract RF data from file
hd = readheader(header);
rfc = readrf(filename, hd);

clear filename header;
%%
% ultrasonix pulse
samplefreq = 40e6;
samplestart = 340;
sampleend = 440;
channel = 128;
dg = 250;
ag = 0.25*(45-24)+24; %in dB

signal = transpose(double(rfc(1,samplestart:sampleend, channel)))./dg./(10^(ag/20));
%%
% hydrophone pulse
samplefreq = 5e9;
samplestart = 2000;
sampleend = 8000;
offset = -8.8495e-004;
ag = 17;

%load unirad_hydrophone1;
signal = double((unirad_hydrophone1(samplestart:sampleend) - offset)./(10^(ag/20)));

%%
figure; plot((0:length(signal)-1).*1/samplefreq,signal);
xlabel('time [s]');
ylabel('voltage [V]');

[FT f] = quickfft(signal,samplefreq);

figure; plot(f./(10^6), 20*log10(abs(FT)));
%figure; plot(f./(10^6), 20*log10(abs(FT)./max(abs(FT))));
xlabel('frequency [MHz]');
ylabel('amplitude [dB]');

%axis([0 20 -50 0]);

clear samplefreq samplestart sampleend channel dg ag offset hd