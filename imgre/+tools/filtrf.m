function [] = filtrf(inPath, f1, f2, fs, varargin)
%
%

import tools.bandpass tools.loadadv tools.saveadv tools.advdouble

if nargin > 4
    outPath = varargin{1};
    
    if isempty(outPath)
        outPath = uigetdir('','Select an output directory');
    end
else
    
    outPath = inPath;
end

if outPath(end) == '/'
    outPath(end) = [];
end

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

% scan directory for rf files and create listing
Listing = struct2cell(dir(strcat(inPath, '/rfg_*')));

if isempty(Listing)
   error('no RF files found in directory'); 
end

nFiles = size(Listing, 2);
FileNames = strcat(repmat(inPath, [nFiles 1]), '/', Listing(1,:).');

for file = 1:nFiles
   
    RfMat = loadadv(FileNames(file,:));
    RffMat = advdouble(bandpass(double(RfMat), 1, f1, f2, fs));
    RffMat.label = RfMat.label;
    RffMat.meta = RfMat.meta;
    
    outFile = strcat(outPath, '/rffg_', ...
        sprintf('%0.4d', RfMat.meta.fileNumber), '.mat');
    saveadv(outFile, RffMat);
end



end

