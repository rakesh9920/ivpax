function [rfcube uHeader] = readsonixb8(filename)

fid = fopen(filename, 'r');
uFileHeader = fread(fid, 19, 'int32');
rfdata = fread(fid, inf, 'uint8');
fclose(fid);

fields = {'type', 'frames', 'w', 'h', 'ss','ulx','uly','urx','ury','brx'...
    ,'bry','blx','bly','probe','txf','sf','dr','ld','extra'};

for f = 1:19
    uHeader.(char(fields(f))) = uFileHeader(f);
end

numOfFrames = uHeader.frames;
samplesPerLine = uHeader.w;
linesPerFrame = uHeader.h;
frameSize = samplesPerLine*linesPerFrame;

rfcube = zeros(linesPerFrame, samplesPerLine, numOfFrames,'uint8');

for frame = 1:numOfFrames
    
    front = (frame-1)*frameSize + 1;
    for line = 1:linesPerFrame
        back =  front + samplesPerLine - 1;
        rfcube(line,:,frame) = rfdata(front:back);
        front = back + 1;
    end
end




