function [RfCube, uHeader] = readsonixb32(filename)
%READSONIXB32 Reads *.b32 ultrasonix files containing 8-bit XRGB data into
%a matrix with dimensions height, width, R:G:B, frame.

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
RfCube = reshape(RfStream, [4 width height nFrames]);

% permute dimensions into the order: height, width, color channel, frame
% normalize RGB values so that 0.0 <= value <= 1.0
RfCube = permute(RfCube, [3 2 1 4]);

% remove last color channel (X) which is unused
RfCube(:,:,4,:) = [];




