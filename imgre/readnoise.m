filename = 'rfdata/sonix_noise_airplate2';

rf = 0;
ft = 0;
L = 1221;
NFFT = 2^nextpow2(L);

numParts = 1;
sig = zeros(1,1221*24700*1);
xc = zeros(1,199999);

prog = progress(0,0,'FFT');
for part = 1:numParts
    
    progress(part/numParts,0,'FFT',prog);
    name = strcat(filename,'_p', num2str(part), '.rf');
    fid = fopen(name, 'r');
    start = 1;
    stop = 1221;
    
    for line = 1:24700
        
        rf = fread(fid, 1620, 'int16=>double');
        sig(1,start:stop) = rf(400:end);
        ft = ft + fft(rf(400:end), NFFT)./L./numParts; 
        start = stop + 1;
        stop = stop + 1221;
    end
    
    fclose(fid);
    
    for piece = 1:300
       st = 1 + 100000*(piece-1);
       sp = st + 100000 - 1;
       xc = xc + xcorr(sig(st:sp));
    end
end

%f = 40e6/2*linspace(0,1,NFFT/2+1);
%F = 20*log10(abs(2*ft(1:NFFT/2+1))./max(abs(2*ft(1:NFFT/2+1))));
F = 20*log10(abs(2*ft(1:NFFT/2+1)));

clear L NFFT fid filename line part prog start stop rf name
%%

plot(f./(10^6), F);
xlabel('frequency [MHz]');
ylabel('amplitude [dB]');
%axis([0 max(f./1e6) -100 0]);

%%

