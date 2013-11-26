function [RfMat] = run_sim_multi(scriptFile, sctFile, varargin)
% Runs calc_scat_multi in Field II using the field and transducer
% definitions in scriptFile and scatterer info in sctFile

import fieldii.field_init
import fieldii.calc_scat_multi
import fieldii.field_end
import tools.loadmat
import tools.advdouble
addpath ./bin/Mat_field.mexw64
addpath ./bin/Mat_field.mexa64

if nargin > 2
    outDir = varargin{1};
    if outDir(end) ~= '/'
        outDir = strcat(outDir, '/');
    end
else
    pathstr = fileparts(sctFile);
    outDir = strcat(pathstr, '/');
end

% load sctFile and read meta data
ScatInfo = loadmat(sctFile);
fileNo = ScatInfo.Meta.fileNo;

outFile = strcat(outDir, 'rf_', sprintf('%0.4d', fileNo));

% run Field II
field_init(-1);

run(scriptFile);

[RfMat, startTime] = calc_scat_multi(TxArray, RxArray, double(ScatInfo(:,1:3)), ...
    double(ScatInfo(:,4)));

field_end;

% write metadata and save output
RfMat = advdouble(RfMat, {'rf', 'scatterer'});
RfMat.Meta.fileNo = fileNo;
RfMat.Meta.startTime = startTime;

if nargout == 0
    save(outFile, 'RfMat');
end

end

