function [rfCube] = stitchrf(filename, header)
% Combines multi-part RF files into a single file

frameSize = header.frameSize;
linesPerFrame = header.linesPerFrame;
totalParts = header.totalParts;
samplesPerLine = frameSize/(2*linesPerFrame);

numOfChannels = 128;

rfCube = zeros(linesPerFrame/numOfChannels*totalParts, samplesPerLine, numOfChannels, 'int16');  

front = 1;
for part = 1:totalParts

    partName = strcat(filename, '_p', num2str(part));
    back = front + linesPerFrame/numOfChannels - 1;
    rfCube(front:back,:,:) = readrf(partName, header);
    front = back + 1;
end

header.totalParts = 1;
header.frameSize = frameSize*totalParts;
header.linesPerFrame = totalParts*linesPerFrame;

writeheader(header, filename);
writerf(rfCube, strcat(filename,'.rf'));
