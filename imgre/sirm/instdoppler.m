function [vest] = instdoppler(bfm)
%

[numlines numsamples numframes] = size(bfm);
vest = zeros(numlines, numsamples);

for line = 1:numlines
    
    for sample = 1:numsamples
        
        ssig = squeeze(bfm(line, sample, :));
        
        asig = hilbert(ssig);
        
        rsig = real(asig);
        isig = imag(asig);
        
        n1 = isig(2:numframes).*rsig(1:(numframes-1));
        n2 = rsig(2:numframes).*isig(1:(numframes-1));
        d1 = rsig(2:numframes).*rsig(1:(numframes-1));
        d2 = isig(2:numframes).*isig(1:(numframes-1));
        
        vest(line, sample) = atan(sum(n1 - n2)/sum(d1 + d2));
    end
end

end

