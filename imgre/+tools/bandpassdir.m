function [] = bandpassdir(inPath, f1, f2, fs, varargin)
% Bandpass filter rf files in a directory.

import tools.bandpass tools.loadadv tools.saveadv tools.advdouble tools.querydir

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

[FileNames, nFiles] = querydir(inPath, 'rf_');

for file = 1:nFiles
   
    RfMat = loadadv(FileNames{file});
    
    FiltMat = advdouble(bandpass(double(RfMat), 1, f1, f2, fs));
    FiltMat.label = RfMat.label;
    FiltMat.meta = RfMat.meta;
    
    FiltMat.meta.filtered = true;
    FiltMat.meta.lowCutoff = f1;
    FiltMat.meta.highCutoff = f2;
    
    outFile = strcat(outPath, '/rf_', ...
        sprintf('%0.4d', RfMat.meta.fileNumber), '.mat');
    saveadv(outFile, FiltMat);
end



end

