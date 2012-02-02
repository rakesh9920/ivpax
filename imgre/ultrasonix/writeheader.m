function [] = writeheader(header, dest)
% Writes header file for RF files

if isfield(header,'minAngle')
    ext = '.sch';
else
    ext = '.bmh';
end

fid = fopen(strcat(dest,ext),'w');
len = length(header.baseName);
fwrite(fid, header.baseName, 'char');
fwrite(fid, zeros(1,50-len), 'char'); 
fwrite(fid, header.frameSize, 'int32');
fwrite(fid, header.linesPerFrame, 'int32');
fwrite(fid, header.totalParts, 'int32');
fwrite(fid, header.beamformed, 'int32');
fwrite(fid, header.focus, 'int32');

if isfield(header,'minAngle')
    fwrite(fid, header.minAngle, 'int32');
    fwrite(fid, header.maxAngle, 'int32');
    fwrite(fid, header.angleIncrement, 'int32');
end

fclose(fid);
end

