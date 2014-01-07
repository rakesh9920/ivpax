function [FileNames, nFiles] = querydir(inPath, heading)
% Searches directory for files matching the specified heading and returns a
% file listing.

if inPath(end) == '/'
    inPath(end) = [];
end

% scan directory for rf files and create listing
Listing = struct2cell(dir(strcat(inPath, '/', heading, '*')));

if isempty(Listing)
    
    nFiles = 0;
    FileNames = [];
else
    
    nFiles = size(Listing, 2);
    FileNames = strcat(repmat(inPath, [nFiles 1]), '/', Listing(1,:).');
end

end

