function [bfline bfmat] = gfbeamform(rxsignals, txpts, rxpts, fldpts)
% General frequency beamformer (for synthetic RF data)

numfldpts = size(fldpts,2);
[numsigs siglength numinst] = size(rxsignals);

global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

txdelay = sqrt(sqdistance(txpts, fldpts))./SOUND_SPEED;
rxdelay = sqrt(sqdistance(rxpts, fldpts))./SOUND_SPEED;

if nargout > 1
    totaldelay = rxdelay;
else
    totaldelay = bsxfun(@plus, rxdelay, txdelay); %rxdist + repmat(txdist,4,1);
end

bfline = zeros(1, numfldpts, numinst);
bfmat = zeros(siglength ,numfldpts, numinst);

nfft = 2^nextpow2(3*siglength);
frontpad = zeros(numsigs, floor((nfft-siglength)/2), numinst);
backpad = zeros(numsigs, nfft-siglength-size(frontpad, 2), numinst);
padsignals = [frontpad rxsignals backpad];

RXSIGNALS = fft(padsignals, [], 2);

f = SAMPLE_FREQUENCY/2*linspace(0,1,nfft/2+1);
freq = [f(1:end-1) -f(end) -fliplr(f(2:(end-1)))];

bar = upicbar('Beamforming ...');
for inst = 1:numinst
    
    RX = squeeze(RXSIGNALS(:,:,inst));
    for fp = 1:numfldpts
        
        upicbar(bar, ((inst-1)*numfldpts + fp)/(numinst*numfldpts));
        
        delays = -totaldelay(:, fp);
        delind = (delays > (siglength/SAMPLE_FREQUENCY)) | (delays < -(siglength/SAMPLE_FREQUENCY));
        
        if all(delind)
            continue
        end

        delays(delind) = [];
        BFSIG = exp(-2*pi*1i.*delays*freq).*RX;
        bfsig = real(ifft(BFSIG, [], 2));
        sumsig = sum(bfsig);
        front = size(frontpad,2)+1;
        bfline(1, fp, inst) = sumsig(front + round(txdelay(:,fp).*SAMPLE_FREQUENCY));
        bfmat(:, fp, inst) = sumsig(front:(front+siglength-1));
    end
end
end
