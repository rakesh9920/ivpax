function [] = addwgndir(inPath, dBLevel, varargin)
% Add white gaussian noise to rf files in a directory.

import tools.addwgn tools.querydir

if nargin > 2
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

[FileNames, nFiles] = querydir(inPath, 'rf_');

for file = 1:nFiles
   
    RfMat = loadadv(FileNames(file,:));
    
    WgnMat = advdouble(addwgn(1, double(RfMat), dBLevel));
    WgnMat.label = RfMat.label;
    WgnMat.meta = RfMat.meta;
    
    WgnMat.meta.addedWgn = true;
    WgnMat.meta.dBLevel = dBLevel;
    
    outFile = strcat(outPath, '/rf_', ...
        sprintf('%0.4d', RfMat.meta.fileNumber), '.mat');
    saveadv(outFile, WgnMat);
end

end

