function rfc_c = zeromean(rfc)

[numLines numSamples numChannels] = size(rfc);
rfc_c = zeros(numLines, numSamples, numChannels);

for line = 1:numLines
    for channel = 1:numChannels
        rfc_c(line,:, channel) =  rfc(line,:, channel) - mean(rfc(line, 100:end, channel));
    end
end
end