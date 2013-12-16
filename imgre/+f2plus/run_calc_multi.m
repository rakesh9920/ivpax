function [RfMat] = run_calc_multi(defHandle, sctFile, varargin)
% Runs calc_scat_multi in Field II using the field and transducer
% definitions and target info.

import fieldii.field_init
import fieldii.calc_scat_multi
import fieldii.field_end
import tools.loadadv
import tools.saveadv
import tools.advdouble
addpath ./bin/

if nargin > 2
    outPath = varargin{1};
    
    if isempty(outPath)
        outPath = uigetdir('','Select an output directory');
    end
    
    if outPath(end) == '/'
        outPath(end) = [];
    end
else
    outPath = fileparts(sctFile);
end

if ~exist(outPath, 'dir')
    mkdir(outPath);
end

% load sctFile
TargetInfo = loadadv(sctFile);

% run Field II
field_init(-1);

[Prms, TxArray, RxArray] = defHandle();

[RfMat, startTime] = calc_scat_multi(TxArray, RxArray, double(TargetInfo(:,1:3)), ...
    double(TargetInfo(:,4)));

field_end;

% write metadata and save output
RfMat = advdouble(RfMat, {'sample', 'channel'});
RfMat.meta.numberOfSamples = size(RfMat, 1);
RfMat.meta.numberOfChannels = size(RfMat, 2);
RfMat.meta.sampleFrequency = Prms.fs;
RfMat.meta.soundSpeed = Prms.c;
RfMat.meta = TargetInfo.meta;
RfMat.meta.startTime = startTime;

outFile = strcat(outPath, '/', 'rf_', sprintf('%0.4d', RfMat.meta.fileNumber));

if nargout == 0
    saveadv(outFile, RfMat);
end

end

