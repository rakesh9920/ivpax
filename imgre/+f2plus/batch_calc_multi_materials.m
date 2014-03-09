function [RfMatTemp] = batch_calc_multi_materials(cfgPath, sctPath, varargin)
%BATCH_CALC_MULTI_CUSTOMBSC

import fieldii.field_init fieldii.calc_scat_multi_custombsc fieldii.field_end
import tools.loadadv tools.saveadv tools.advdouble tools.dirprompt tools.varorfile
addpath ./bin/

%% INPUT HANDLING
Parser = inputParser;
Parser.KeepUnmatched = true;
Parser.addOptional('OutputDirectory', 'noinput');
Parser.parse(varargin{:});
Prms = Parser.Results;
outDir = Prms.OutputDirectory;

SctMat = varorfile(sctPath, @loadadv);

if strcmpi(OutDir, 'noinput')
    if isa(sctPath, 'char')
        outDir = fileparts(sctPath);
    else
        outDir = './';
    end
else
    outDir = dirprompt(outDir);
end

if isa(cfgPath, 'char')
    [cfgDir, cfgName] = fileparts(cfgPath);
    addpath(cfgDir);
    cfgHandle = str2func(cfgName);
else
    cfgHandle = cfgPath;
end

Materials = SctMat.meta.Materials;
nMaterials = size(Materials, 2);

%% START FIELD II
field_init(-1);

try
    
    [Prms, TxArray, RxArray] = cfgHandle();
    
    % loop over each material defined in scattering matrix
    for mat = 1:nMaterials
        
        % find time-domain filter for the material's bsc spectrum
        Filt = bsc2filt(Materials(mat).Bsc, Prms);
        
        % find position info in scattering matrix for the material only
        SctPos = SctMat(SctMat(:,4) == mat, 1:3);
        
        % run field ii and set metadata
        [RfMatTemp, startTime] = calc_scat_multi_custombsc(TxArray, RxArray, SctPos, ...
            Filt);
        RfMatTemp = advdouble(RfMatTemp);
        RfMatTemp.meta.StartTime = startTime;
        RfMatTemp.meta.StartFrame = SctMat.meta.StartFrame;
        RfMatTemp.meta.EndFrame = SctMat.meta.EndFrame;
        
        % align and sum rf data for each material
        if mat == 1
            RfMat = RfMatTemp;
        else
            RfMat = alignsumrf(RfMat, RfMatTemp);
        end
    end
    
catch err
    
    field_end;
    rethrow(err)
end

field_end;
% END FIELD II

%% METADATA AND OUTPUT HANDLING

RfMat.label = {'sample', 'channel'};
RfMat.meta.Sct = SctMat.meta;
RfMat.meta.F2 = Prms;
RfMat.meta.FileID = SctMat.meta.FileID;
RfMat.meta.NumberOfSamples = size(RfMat, 1);
RfMat.meta.NumberOfChannels = size(RfMat, 2);
RfMat.meta.SampleFrequency = Prms.fs;
RfMat.meta.SoundSpeed = Prms.c;
RfMat.meta.StartTime = startTime;
RfMat.meta.TxPositions = Prms.TxPos;
RfMat.meta.RxPositions = Prms.RxPos;

if nargout == 0
    
    outPath = fullfile(outDir, ['rf_', sprintf('%0.4d', RfMat.meta.FileID)]);
    saveadv(outPath, RfMat);
end

end

