function [temp] = fcfilter(rfcube, f1, f2, f3, bw, fs)
% Applies frequency compounding to RF data

fl = (f1 - bw/2)/(fs/2);
fu = (f1 + bw/2)/(fs/2);
[z,p,k] = butter(6,[fl fu]); % bandpass filter
[sos,g] = zp2sos(z,p,k);
hd1 = dfilt.df2sos(sos, g);

fl = (f2 - bw/2)/(fs/2);
fu = (f2 + bw/2)/(fs/2);
[z,p,k] = butter(6,[fl fu]); % bandpass filter
[sos,g] = zp2sos(z,p,k);
hd2 = dfilt.df2sos(sos, g);


fl = (f3 - bw/2)/(fs/2);
fu = (f3 + bw/2)/(fs/2);
[z,p,k] = butter(6,[fl fu]); % bandpass filter
[sos,g] = zp2sos(z,p,k);
hd3 = dfilt.df2sos(sos, g);

[numOfLines numOfSamples numOfChannels] = size(rfcube);
temp = zeros(numOfLines, numOfSamples, numOfChannels, class(rfcube));

prog = progress(0,0,'Filtering');
for x = 1:numOfLines
    
    progress(x/numOfLines,0,'Filtering',prog);
    
    for y = 1:numOfChannels
        
        sig1 =  filter(hd1, double(rfcube(x,:,y)));
        sig2 =  filter(hd2, double(rfcube(x,:,y)));
        sig3 =  filter(hd3, double(rfcube(x,:,y)));
        temp(x,:,y) = (1/3).*(sig1 + sig2 +sig3);
    end
end

end

