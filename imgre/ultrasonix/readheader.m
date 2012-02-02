function [header] = readheader(filename)
% Reads header files for RF data

pos = find(filename == '.') + 1;

if isempty(pos)
    error('Invalid filename and/or extension');
else
    ext = filename(pos:length(filename));
end

fid = fopen(filename, 'r');
h1 = fread(fid, 50, 'char');
h2 = fread(fid, inf, 'int32');
fclose(fid);

switch (ext)
    case 'bmh'
        header = readBMH(h1,h2);
    case 'sch'
        header = readSCH(h1,h2);
    otherwise
        error('File extension not supported');
end

end

function header = readBMH(h1,h2)

length = sum(h1 ~= 0);

header.baseName = char(transpose(h1(1:length)));
header.frameSize = h2(1); % number of bytes in each frame
header.linesPerFrame = h2(2); % number of lines in a frame
header.totalParts = h2(3); % number of frames in an entire data set
header.beamformed = h2(4);
header.focus = h2(5); % focus distance in microns

end

function header = readSCH(h1,h2)

header = readBMH(h1,h2);
header.minAngle = h2(6);
header.maxAngle = h2(7);
header.angleIncrement = h2(8);
end

