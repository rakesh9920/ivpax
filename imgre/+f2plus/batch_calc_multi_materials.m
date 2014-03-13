function [RfMat] = batch_calc_multi_materials(cfgPath, sctPath, varargin)
%BATCH_CALC_MULTI_CUSTOMBSC

import fieldii.field_init f2plus.calc_multi_custombsc fieldii.field_end
import f2plus.bsc2filt tools.alignsumrf
import tools.loadadv tools.saveadv tools.advdouble tools.dirprompt tools.varorfile
addpath ./bin/

%% INPUT HANDLING
Parser = inputParser;
Parser.KeepUnmatched = true;
Parser.addOptional('OutputDirectory', 'noinput');
Parser.addOptional('Filename', []);
Parser.addOptional('ConfigInputs', {});
Parser.parse(varargin{:});
Prms = Parser.Results;
outDir = Prms.OutputDirectory;
outFile = Prms.Filename;
ConfigInputs = Prms.ConfigInputs;

SctMat = varorfile(sctPath, @loadadv);

if strcmpi(outDir, 'noinput')
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
    
    [Prms, TxArray, RxArray] = cfgHandle(ConfigInputs{:});
    
    % loop over each material defined in scattering matrix
    for mat = 1:nMaterials
        
        % find time-domain filter for the material's bsc spectrum
        Filt = bsc2filt(Materials(mat).Bsc, Prms);
        
        % find position info in scattering matrix for the material only
        SctPos = double(SctMat(SctMat(:,4) == mat, 1:3));
        
        % run field ii and set metadata
        [RfMatTemp, startTime] = calc_multi_custombsc(TxArray, RxArray, ...
            double(SctPos), Filt, Prms.SampleFrequency);
        
        RfMatTemp = advdouble(RfMatTemp);
        RfMatTemp.meta.StartTime = startTime;
        RfMatTemp.meta.StartFrame = SctMat.meta.StartFrame;
        RfMatTemp.meta.EndFrame = SctMat.meta.EndFrame;
        RfMatTemp.meta.SampleFrequency = Prms.SampleFrequency;
        
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
RfMat.meta.SampleFrequency = Prms.SampleFrequency;
RfMat.meta.SoundSpeed = Prms.SoundSpeed;
RfMat.meta.TxPositions = Prms.TxPositions;
RfMat.meta.RxPositions = Prms.RxPositions;

if nargout == 0
    
    if isempty(outFile)
        outPath = fullfile(outDir, ['rf_', sprintf('%0.4d', RfMat.meta.FileID)]);
    else
        outPath = fullfile(outDir, outFile);
    end
    
    saveadv(outPath, RfMat);
end

end

