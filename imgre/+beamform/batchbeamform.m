function [BfMat] = batchbeamform(defHandle, RfFile, section, nSection, varargin)
%RUNGFBEAMFORM4 Summary of this function goes here

import beamform.gfbeamform5
import tools.loadadv
import tools.advdouble

if isa(defHandle, 'char')
    defHandle = str2func(defHandle);
end

if isa(RfFile, 'char')
    RfFile = loadadv(RfFile);
end

if nargin > 4
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

TxPos = RfFile.meta.transmitPosition;
RxPos = RfFile.meta.receivePosition;

[FieldPos, Prms, nWinSample] = defHandle(section, nSection);

BfMat = advdouble(gfbeamform5(double(RfFile), TxPos, RxPos, FieldPos, ...
    nWinSample, Prms));

BfMat.label = {'sample', 'frame', 'position'};
BfMat.meta.sampleFrequency = RfFile.meta.sampleFrequency;
BfMat.meta.startFrame = RfFile.meta.startFrame;
BfMat.meta.endFrame = RfFile.meta.endFrame;
BfMat.meta.fieldPosition = FieldPos;

if nargout == 0
    saveadv(outPath, BfMat);
end

end

