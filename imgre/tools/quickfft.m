function [F f] = quickfft(sig, varargin)

if nargin > 1
    Fs = varargin{1}; % sampling frequency
else
    Fs = 40*10^6; % sampling frequency
end

L = length(sig);
%NFFT = 2^nextpow2(L);
NFFT = 100000;
ft = fft(double(sig),NFFT)/L;

f = Fs/2*linspace(0,1,NFFT/2+1);
figure;
F = 20*log10(abs(2*ft(1:NFFT/2+1))./max(abs(2*ft(1:NFFT/2+1))));
%F = 20*log10(abs(2*ft(1:NFFT/2+1)));
plot(f./(10^6), F);

xlabel('frequency [MHz]');
ylabel('amplitude [dB]');
%axis([0 max(f./1e6) -50 0]);
axis([0 20 -50 0]);

end

