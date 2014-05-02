function [RfMat] = batch_calc_multi(cfgPath, sctPath, varargin)
%BATCH_CALC_MULTI Runs calc_scat_multi in Field II using the field and transducer
% definitions and target info.

import fieldii.field_init fieldii.calc_scat_multi fieldii.field_end
import tools.loadadv tools.saveadv tools.advdouble tools.dirprompt tools.varorfile
addpath ./bin/

SctMat = varorfile(sctPath, @loadadv);

if nargin > 2
    outDir = dirprompt(varargin{1});
elseif isa(sctPath, 'char')
    outDir = fileparts(sctPath);
else
    outDir = './';
end

if isa(cfgPath, 'char')
    [cfgDir, cfgName] = fileparts(cfgPath);
    addpath(cfgDir);
    cfgHandle = str2func(cfgName);
else
    cfgHandle = cfgPath;
end

% run Field II
field_init(-1);

try
    
    [Prms, TxArray, RxArray, TxPos, RxPos] = cfgHandle();
    [RfMat, startTime] = calc_scat_multi(TxArray, RxArray, double(SctMat(:,1:3)), ...
        double(SctMat(:,4)));
catch err
    
    field_end;
    rethrow(err)
end

field_end;

% write metadata and save output
RfMat = advdouble(RfMat, {'sample', 'channel'});
RfMat.meta = SctMat.meta;
RfMat.meta.numberOfSamples = size(RfMat, 1);
RfMat.meta.numberOfChannels = size(RfMat, 2);
RfMat.meta.sampleFrequency = Prms.fs;
RfMat.meta.soundSpeed = Prms.c;
RfMat.meta.startTime = startTime;
RfMat.meta.transmitPosition = TxPos;
RfMat.meta.receivePosition = RxPos;

if nargout == 0
    
    outPath = fullfile(outDir, ['rf_', sprintf('%0.4d', RfMat.meta.fileNumber)]);
    saveadv(outPath, RfMat);
end

end
