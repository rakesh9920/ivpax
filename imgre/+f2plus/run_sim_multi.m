function [] = run_sim_multi(scriptFile, sctFile, varargin)

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

ScatInfo = loadmat(sctFile);
fileNo = ScatInfo.meta.fileNo;

outFile = strcat(outDir, 'rf_', sprintf('%0.4d', fileNo));

field_init(-1)

run(scriptFile)

[RfMat, startTime] = calc_scat_multi(txArray, rxArray, ScatInfo(:,1:3), ...
    ScatInfo(:,4));





end

