function [RfCube, uHeader] = readsonixrf(filename)
%READSONIXRF Reads *.rf ultrasonix files containing either pre or
%post-beamformed rf data into a matrix with dimensions sample, line, frame.

fid = fopen(filename, 'r');
uFileHeader = fread(fid, 19, 'int32');
RfStream = fread(fid, inf, 'int16=>int16');
fclose(fid);

fields = {'type', 'frames', 'w', 'h', 'ss','ulx','uly','urx','ury','brx'...
    ,'bry','blx','bly','probe','txf','sf','dr','ld','extra'};

for f = 1:19
    uHeader.(char(fields(f))) = uFileHeader(f);
end

nLinesPerFrame = uHeader.w;
nSamplesPerLine = uHeader.h;
nFrames = uHeader.frames;

RfCube = reshape(RfStream, [nSamplesPerLine nLinesPerFrame nFrames]);






