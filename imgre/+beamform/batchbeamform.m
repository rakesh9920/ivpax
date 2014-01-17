function [BfMat] = batchbeamform(defHandle, rfPath, section, nSection, varargin)
%BATCHBEAMFORM Runs beamformer using the specified definition file for the
%inputed RF data and volumetric section.

import beamform.gtbeamform2
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

BfMat = advdouble(gtbeamform2(double(RfMat), TxPos, RxPos, FieldPos, ...
    nWinSample, Prms));

BfMat.label = {'sample', 'frame', 'position'};
BfMat.meta = RfMat.meta;
BfMat.meta.fieldPosition = FieldPos;
BfMat.meta.volumeNumber = section;

if nargout == 0
    
    outPath = fullfile(outDir, ['bf_' sprintf('%0.4d', RfMat.meta.fileNumber)...
        '_' sprintf('%0.4d', section)]);
    saveadv(outPath, BfMat);
end

end

