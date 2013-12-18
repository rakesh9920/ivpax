function [BfMat] = rungfbeamform4(defHandle, RfFile, section, varargin)
%RUNGFBEAMFORM4 Summary of this function goes here

import beamform.gfbeamform4
import tools.loadadv
import tools.advdouble

if isa(defHandle, 'char')
    defHandle = str2func(defHandle);
end

if isa(RfFile, 'char')
    RfFile = loadadv(RfFile);
end

if nargin > 3
    outPath = varargin{1};
    
    if isempty(outPath)
        outPath = uigetdir('','Select an output directory');
    end
    
elseif isa(RfFile, 'char')
    outPath = fileparts(RfFile);
else
    outPath = './';
end

if outPath(end) == '/'
    outPath(end) = [];
end

if ~exist(outPath, 'dir')
    mkdir(outPath);
end

[TxPos, RxPos, FieldPos, Prms] = defHandle(section);

BfMat = advdouble(gfbeamform4(double(RfFile), TxPos, RxPos, FieldPos, Prms));

BfMat.label = {'sample', 'position', 'frame'};
BfMat.meta.sampleFrequency = RfFile.meta.sampleFrequency;
BfMat.meta.startFrame = RfFile.meta.startFrame;
BfMat.meta.endFrame = RfFile.meta.endFrame;
BfMat.meta.pixelPositions = FieldPos;

if nargout > 0
    saveadv(outPath, BfMat);
end

end

