function [RfMat] = run_sim_multi(scriptFile, sctFile, varargin)
% Runs calc_scat_multi in Field II using the field and transducer
% definitions in scriptFile and scatterer info in sctFile

import fieldii.field_init fieldii.calc_scat_multi
import tools.loadmat

if nargin > 2
    outDir = varargin{1};
else
    outDir = [];
end

if outDir(end) ~= '/'
    outDir = strcat(outDir, '/');
end

% load sctFile and read meta data
ScatInfo = loadmat(sctFile);
fileNo = ScatInfo.Meta.fileNo;

outFile = strcat(outDir, 'rf_', sprintf('%0.4d', fileNo));

% run Field II
field_init(-1)

run(scriptFile)

[RfMat, startTime] = calc_scat_multi(txArray, rxArray, ScatInfo(:,1:3), ...
    ScatInfo(:,4));

xdc_free(txArray);
xdc_free(rxArray);

field_end;

% write metadata and save output
RfMat = advdouble(RfMat, {'rf', 'scatt'});
RfMat.Meta.startTime = startTime;
RfMat.Meta.fileNo = fileNo;

if nargout == 0
    save(outFile, 'RfMat');
end

end

