function [rfcube, uHeader] = readsonixrf(filename)

fid = fopen(filename, 'r');
uFileHeader = fread(fid, 19, 'int32');
rfdata = fread(fid, inf, 'int16');
fclose(fid);

fields = {'type', 'frames', 'w', 'h', 'ss','ulx','uly','urx','ury','brx'...
    ,'bry','blx','bly','probe','txf','sf','dr','ld','extra'};

for f = 1:19
    uHeader.(char(fields(f))) = uFileHeader(f);
end

linesPerFrame = uHeader.w;
samplesPerLine = uHeader.h;
numOfFrames = uHeader.frames;
frameSize = linesPerFrame*samplesPerLine;

rfcube = zeros(linesPerFrame, samplesPerLine, numOfFrames);
%rfcube = readRF(filename, header);

for frame = 1:numOfFrames
    
    front = (frame-1)*frameSize + 1;
    for line = 1:linesPerFrame
        back =  front + samplesPerLine - 1;
        rfcube(line,:,frame) = rfdata(front:back);
        front = back + 1;
    end
end





