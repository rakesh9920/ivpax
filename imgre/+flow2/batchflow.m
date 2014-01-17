function [VelMat] = batchflow(fun, def, inPath, varargin)
%BATCHFLOW

import tools.varorfile tools.dirprompt tools.loadadv tools.saveadv tools.advdouble
import flow2.instflow

if isa(fun, 'char')
    fun = str2func(fun);
end

if isa(def, 'char')
    def = str2func(def);
end

if nargin > 2
    outDir = dirprompt(varargin{1});
elseif isa(inPath, 'char')
    outDir = fileparts(inPath);
else
    outDir = './';
end

BfMat = varorfile(inPath, @loadadv);

Prms = def();

VelMat = advdouble(fun(double(BfMat), Prms));
VelMat.label = {'estimate', 'frame', 'position'};
VelMat.meta = BfMat.meta;

if nargout == 0
    
    fileNumber = VelMat.meta.fileNumber;
    volumeNumber = VelMat.meta.volumeNumber;
    
    outPath = fullfile(outDir, ['ve_' sprintf('%0.4d', fileNumber) ...
        '_' sprintf('%0.4d', volumeNumber)]);
    
    saveadv(outPath, VelMat);
end

