function [FT f F] = qfft2(sig, Fs)

L = size(sig,2);
NFFT = 2^nextpow2(L);
%NFFT = 100000;

ft = fft(double(sig),NFFT, 2)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
FT = 2*ft(:,1:NFFT/2+1);
%F = 20*log10(abs(FT)./max(FT));

end

