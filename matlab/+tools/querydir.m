function [FileNames, nFiles] = querydir(inPath, heading)
% Searches directory for files matching the specified heading and returns a
% file listing with full path in a cell array.

if inPath(end) ~= '/'
    inPath = [inPath '/'];
end

% scan directory for rf files and create listing
%Listing = struct2cell(dir([inPath heading '*']));
Listing = dir([inPath heading '*']);

FileNames = cellfun(@(x) strcat(inPath, x), {Listing(~[Listing.isdir]).name},...
    'UniformOutput', false).';
nFiles = size(FileNames, 1);

% if isempty(Listing)
%     
%     nFiles = 0;
%     FileNames = [];
%     
% else
%     
%     nFiles = size(Listing, 2);
%     FileNames = [repmat(inPath, [nFiles 1]) Listing(1,:).'];
% end

end

