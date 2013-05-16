function [vest] = instdoppler(bfm)
%

[numlines numsamples numframes] = size(bfm);
vest = zeros(numlines, numsamples);

t = ((0:numframes-1)./(60)).';
for line = 1:numlines
    
    for sample = 1:numsamples
        
        ssig = squeeze(bfm(line, sample, :));
        
        asig = hilbert(ssig);
        rsig = real(asig);
        isig = imag(asig);
        
        %rsig = ssig.*sin(2*pi*10e6.*t);
        %isig = ssig.*cos(2*pi*10e6.*t);
        
        n1 = isig(2:numframes).*rsig(1:(numframes-1));
        n2 = rsig(2:numframes).*isig(1:(numframes-1));
        d1 = rsig(2:numframes).*rsig(1:(numframes-1));
        d2 = isig(2:numframes).*isig(1:(numframes-1));
        
        vest(line, sample) = atan(sum(n1 - n2)/sum(d1 + d2));
        %vest(line, sample) = mean(diff(angle(asig)));
    end
end

end

