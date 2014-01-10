function [BfMat] = batchbeamform(defHandle, rfPath, section, nSection, varargin)
%BATCHBEAMFORM Runs beamformer using the specified definition file for the
%inputed RF data and volumetric section.

import beamform.gfbeamform5
import tools.loadadv tools.saveadv tools.advdouble tools.varorfile tools.dirprompt

if isa(defHandle, 'char')
    defHandle = str2func(defHandle);
end

RfMat = varorfile(rfPath, @loadadv);

if nargin > 4
    outDir = dirprompt(varargin{1});
elseif isa(rfPath, 'char')
    outDir = fileparts(rfPath);
else
    outDir = './';
end

TxPos = RfMat.meta.transmitPosition;
RxPos = RfMat.meta.receivePosition;

[FieldPos, Prms, nWinSample] = defHandle(section, nSection);

BfMat = advdouble(gfbeamform5(double(RfMat), TxPos, RxPos, FieldPos, ...
    nWinSample, Prms));

BfMat.label = {'sample', 'frame', 'position'};
BfMat.meta = RfMat.meta;
BfMat.meta.fieldPosition = FieldPos;

if nargout == 0
    
    outPath = fullfile(outDir, ['bf_' sprintf('%0.4d', RfMat.meta.fileNumber)...
        '_' sprintf('%0.4d', section)]);
    saveadv(outPath, BfMat);
end

end

% if isa(RfFile, 'char')
%     RfFile = loadadv(RfFile);
% end
% if nargin > 4
%     outPath = varargin{1};
%     if isempty(outPath)
%         outPath = uigetdir('','Select an output directory');
%     end   
% elseif isa(RfMat, 'char')
%     outPath = fileparts(RfMat);
% else
%     outPath = './';
% end
% if outPath(end) == '/'
%     outPath(end) = [];
% end
% if ~exist(outPath, 'dir')
%     mkdir(outPath);
% end
% BfMat.meta.sampleFrequency = RfMat.meta.sampleFrequency;
% BfMat.meta.startFrame = RfMat.meta.startFrame;
% BfMat.meta.endFrame = RfMat.meta.endFrame;
