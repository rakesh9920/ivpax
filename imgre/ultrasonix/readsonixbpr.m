function [rfcube uHeader] = readsonixbpr(filename)

% PROBABLY NEEDS TO BE FIXED

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
samplesPerLine = uHeader.h;
linesPerFrame = uHeader.w;
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

%{
img = rf(:,:,1);

[R C] = size(img);

mat = zeros(R,C,3,'uint8');

for r = 1:R
    for c = 1:C
        
        str = dec2bin(img(r,c),32);
        mat(r,c,1) = bin2dec(str(9:16));
        mat(r,c,2) = bin2dec(str(17:24));
        mat(r,c,3) = bin2dec(str(25:32));
    end
end
%}


