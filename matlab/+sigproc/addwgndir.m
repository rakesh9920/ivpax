function [] = addwgndir(inDir, dBLevel, varargin)
%ADDWGNDIR Add white gaussian noise to rf files in a directory.

import sigproc.addwgn tools.querydir tools.dirprompt

inDir = dirprompt(inDir);

if nargin > 2
    outDir = dirprompt(varargin{1});
else
    outDir = inDir;
end

[FileNames, nFiles] = querydir(inDir, 'rf_');

for file = 1:nFiles
   
    RfMat = loadadv(FileNames(file,:));
    
    WgnMat = advdouble(addwgn(1, double(RfMat), dBLevel));
    WgnMat.label = RfMat.label;
    WgnMat.meta = RfMat.meta;
    
    WgnMat.meta.addedWgn = true;
    WgnMat.meta.dBLevel = dBLevel;
    
    outPath = fullfile(outDir, ['rf_' sprintf('%0.4d', RfMat.meta.fileNumber)]);
    saveadv(outPath, WgnMat);
end

end

