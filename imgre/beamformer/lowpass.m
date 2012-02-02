function [temp] = lowpass(rfcube, fc, fs)

f1 = fc/(fs/2);
[z,p,k] = butter(12,f1,'low'); % bandpass filter

[sos,g] = zp2sos(z,p,k);
hd = dfilt.df2sos(sos, g);

[numOfLines numOfSamples numOfChannels] = size(rfcube);
temp = zeros(numOfLines, numOfSamples, numOfChannels,class(rfcube));

prog = progress(0,0,'Filtering');
for x = 1:numOfLines
    
    progress(x/numOfLines,0,'Filtering',prog);
    
    for y = 1:numOfChannels
        temp(x,:,y) =  filter(hd, double(rfcube(x,:,y)));
    end
end

end

