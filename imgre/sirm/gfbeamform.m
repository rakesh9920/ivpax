function [bfline] = gfbeamform(rxsignals, txpts, rxpts, fldpts)

numfldpts = size(fldpts,2);
[numsigs siglength numinst] = size(rxsignals);
soundspeed = 1500;
sampfreq = 40e6;

txdist = sqrt(sqdistance(txpts, fldpts));
rxdist = sqrt(sqdistance(rxpts, fldpts));
totaldist = rxdist + repmat(txdist,4,1);

bfline = zeros(1, numfldpts, numinst);

nfft = 2^nextpow2(3*siglength);
frontpad = zeros(numsigs, floor((nfft-siglength)/2), numinst);
backpad = zeros(numsigs, nfft-siglength-size(frontpad, 2), numinst);
padsignals = [frontpad rxsignals backpad];

RXSIGNALS = fft(padsignals, [], 2);

f = sampfreq*linspace(0,1,nfft/2+1);
freq = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];

bar = upicbar('Beamforming ...');
for inst = 1:numinst
    
    RX = squeeze(RXSIGNALS(:,:,inst));
    for fp = 1:numfldpts
        
        upicbar(bar, inst*fp/(numinst*numfldpts));
        
        dist = totaldist(:, fp);
        delays = -dist./soundspeed;
        delind = (delays > (siglength/sampfreq)) | (delays < -siglength/sampfreq);
        
        if all(delind)
            continue
        end
%       
%         EXP1 = exp(-2*pi*1i.*delays*freq(1:(nfft/2)));
%         EXP2 = conj(exp(-2*pi*1i.*delays*freq(nfft/2+1)));
%         EXP3 = conj(exp(-2*pi*1i.*delays*freq(2:(nfft/2))));
        
%         BFSIG = [EXP1 EXP2 EXP3].*RX;
        BFSIG = exp(-2*pi*1i.*delays*freq).*RX;
        bfsig = real(ifft(BFSIG, [], 2));
        bfsig(delind,:) = [];
        sumsig = sum(bfsig);
        bfline(1, fp, inst) = sumsig(size(frontpad,2)+1);
        
%         sum = 0;
%         for d = 1:length(delays)
%             if delays(d) > size(rxsignals, 2) || delays(d) < 1
%                 continue
%             end
%             sum = sum + rxsignals(d, delays(d), inst);
%         end
%         
%         bfline(1, fp, inst) = sum;
    end
end
end
