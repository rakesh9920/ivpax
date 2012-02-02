function [rfcube] = readrf(filename, header)
% Reads an RF file

frameSize = header.frameSize;
linesPerFrame = header.linesPerFrame;
samplesPerLine = frameSize/(2*linesPerFrame);

% open file and read binary data
fid = fopen(filename, 'r');
[rfdata] = fread(fid, inf, 'int16');
fclose(fid);

if header.beamformed == 1
    rfcube = readBFRF(rfdata, linesPerFrame, samplesPerLine);
else  
    rfcube = readNonBFRF(rfdata, linesPerFrame, samplesPerLine);
end

% subfunctions
function [rfmat] = readBFRF(rfdata, linesPerFrame, samplesPerLine) 

rfmat = zeros(linesPerFrame, samplesPerLine, 'int16');

front = 1;
for line = 1:linesPerFrame
    back =  front + samplesPerLine - 1;
    rfmat(line,:) = rfdata(front:back);
    front = back + 1;
end

function [rfcube] = readNonBFRF(rfdata, linesPerFrame, samplesPerLine)

numOfChannels = 128;
rfcube = zeros(linesPerFrame/numOfChannels, samplesPerLine, numOfChannels, 'int16');

front =  1;
for line = 1:(linesPerFrame/numOfChannels)
    for channel = 1:numOfChannels
        back =  front + samplesPerLine - 1;
        rfcube(line,:,channel) = rfdata(front:back);
        front = back + 1;
    end
end


