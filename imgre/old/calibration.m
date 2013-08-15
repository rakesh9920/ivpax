%%
filename = 'rfdata/pulse1.rf'; % path to RF file
header = 'rfdata/pulse1.bmh'; % path to BMH file

% Extract RF data from file
hd = readheader(header);
rfc = readrf(filename, hd);

clear filename header;

%%
% ultrasonix pulse
samplefreq = 40e6;
samplestart = 1810;
sampleend = 1900;
channel = 64;
dg = 500;
ag = 0.50*(45-24)+24; %in dB

signal = transpose(double(rfc(1,samplestart:sampleend, channel)))./dg./(10^(ag/20));

%%
% ultrasonix train
samplefreq = 40e6;
samplestart = 1880;
sampleend = 2060;
channel = 64;
dg = 500;
ag = 0.50*(45-24)+24; %in dB

signal = transpose(double(rfc(1,samplestart:sampleend, channel)))./dg./(10^(ag/20));

%%
% hydrophone pulse
samplefreq = 1e9;
samplestart = 4600;
sampleend = 5300;
offset = 3.1764e-005;
ag = 17;

load pulse1;
signal = double((pulse1(samplestart:sampleend) - offset)./(10^(ag/20)));
%%
% hydrophone train
samplefreq = 2.5e9;
samplestart = 1000;
sampleend = 9500;
offset = 9.0573e-004;
ag = 17;

load train1;
signal = double((train1(samplestart:sampleend) - offset)./(10^(ag/20)));

%%
% hydrophone pulse (panametrics)
samplefreq = 5e9;
samplestart = 4500;
sampleend = 8000;
offset = 0;
ag = 17;

load panametric
signal = double((panametric(samplestart:sampleend) - offset)./(10^(ag/20)));

%%
% ultrasonix pulse (panametrics)
samplefreq = 40e6;
samplestart = 1950;
sampleend = 1980;
channel = 64;
dg = 500;
ag = 0.50*(45-24)+24; %in dB

signal = transpose(double(rfc(1,samplestart:sampleend, channel)))./dg./(10^(ag/20));

%%
%figure; plot((0:length(signal)-1).*1/samplefreq,blackmanharris(length(signal)).*signal);
figure; plot((0:length(signal)-1).*1/samplefreq,signal);
xlabel('time [s]');
ylabel('voltage [V]');

%winsignal = blackmanharris(length(signal)).*signal;
[FT f] = quickfft(signal,samplefreq);
%[FT f] = quickfft(winsignal,samplefreq);

figure; plot(f./(10^6), 20*log10(abs(FT)));
%figure; plot(f./(10^6), 20*log10(abs(FT)./max(abs(FT))));
xlabel('frequency [MHz]');
ylabel('amplitude [dB]');

%axis([0 20 -50 0]);

clear samplefreq samplestart sampleend channel dg ag offset hd