function [amplified] = gain(rfcube, dbgain)
% Applies digital gain to RF data

[numOfLines numOfSamples numOfChannels] = size(rfcube);

amplified = zeros(numOfLines, numOfSamples, numOfChannels,class(rfcube));

prog = progress(0,0,'Gain');
for l = 1:numOfLines
    
    progress(l/numOfLines,0,'Gain',prog);
    
    for c = 1:numOfChannels
        amplified(l,:,c) = 10^(dbgain/20).*rfcube(l,:,c);      
    end
end

end

