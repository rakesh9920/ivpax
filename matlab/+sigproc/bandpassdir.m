function [] = bandpassdir(inPath, f1, f2, fs, varargin)
% Bandpass filter rf files in a directory.

import tools.bandpass tools.loadadv tools.saveadv tools.advdouble tools.querydir
import tools.dirprompt

inPath = dirprompt(inPath);

if nargin > 4
    outDir = dirprompt(varargin{1});
else
    outDir = dirprompt(inPath);
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
    
    outPath = fullfile(outDir, ['rf_' sprintf('%0.4d', RfMat.meta.fileNumber)]);
    saveadv(outPath, FiltMat);
end

end

