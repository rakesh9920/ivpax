function [table] = readctable(filename)

% input arguments error checking
error(nargchk(1, 1, nargin, 'struct'));

fid = fopen(filename,'r');
table = fread(fid,inf,'uint8');
fclose(fid);

end

