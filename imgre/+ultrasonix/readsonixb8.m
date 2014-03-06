function [RfCube, uHeader] = readsonixb8(filename)
%READSONIXB8 Reads *.b8 ultrasonix files containing 8-bit grayscale data into a 
% matrix with dimensions height, width, gs channel, frame.

fid = fopen(filename, 'r');
uFileHeader = fread(fid, 19, 'int32');
RfStream = fread(fid, inf, 'uint8=>uint8');
fclose(fid);

fields = {'type', 'frames', 'w', 'h', 'ss','ulx','uly','urx','ury','brx'...
    ,'bry','blx','bly','probe','txf','sf','dr','ld','extra'};

for f = 1:19
    uHeader.(char(fields(f))) = uFileHeader(f);
end

nFrames = uHeader.frames;
width = uHeader.w;
height = uHeader.h;

% reshape data stream
RfCube = reshape(RfStream, [width height nFrames]);

% permute dimensions into the order: height, width, color channel, frame
RfCube = permute(RfCube, [2 1 3]);





