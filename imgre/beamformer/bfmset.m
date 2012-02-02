function [options] = bfmset(varargin)
%BFMSET creates/modifies bfm options structure
% adapted from ODESET

if (nargin == 0) && (nargout == 0)
    fprintf('       ArrayPitch: [ positive scalar in m ]\n');
    fprintf('      ChannelOmit: [ vector ]\n');
    fprintf(' GaussApodization: [ boolean ]\n');
    fprintf('    GaussWinAlpha: [ positive scalar ]\n');
    fprintf('  HorizPixelPitch: [ positive scalar in m ]\n');
    fprintf('    Photoacoustic: [ boolean ]\n');
    fprintf('       RxCurveBtm: [ positive integer ]\n');
    fprintf('       RxCurveMid: [ positive integer ]\n');
    fprintf('       RxCurveTop: [ positive integer ]\n');
    fprintf('      RxCurveVmid: [ positive integer ]\n');
    fprintf('       SampleFreq: [ positive scalar in Hz ]\n');
    fprintf('        SaveDelay: [ positive scalar in s ]\n');
    fprintf('       SoundSpeed: [ positive scalar in m/s ]\n');
    fprintf('TimeErrorInterval: [ positive scalar in s ]\n');
    fprintf('   VertPixelPitch: [ positive scalar in m ]\n');
    return;
end

% Define options
Names = {
    'ArrayPitch'
    'ChannelOmit'
    'CoherenceWeighting'
    'GaussApodization'
    'GaussWinAlpha'
    'HorizPixelPitch'
    'MinimumVariance'
    'MVSubarrayLength'
    'Photoacoustic'
    'RxApertureCurve'
    'RxCurveTop'
    'RxCurveMid'
    'RxCurveBtm'
    'RxCurveDepth'
    'RxCurveVmid'
    'RxMaxElements'
    'SampleFreq'
    'SaveDelay'
    'SoundSpeed'
    'TimeErrorInterval'
    'VertPixelPitch'
    };
Names = deblank(Names);
nNames = size(Names,1);

% Initialize options struct
options = [];
for j = 1:nNames
    options.(Names{j}) = [];
end

% Combine options structs from input arguments (if any)
argNo = 1;
while argNo <= nargin
    
    argument = varargin{argNo};
    if ischar(argument)
        break;
    end
    if ~isempty(argument)
        if ~isa(argument, 'struct')
            error(message('bfmset:No property names or structures'));
        end
        
        for fieldNo = 1:nNames
            if any(strcmp(fieldnames(argument),Names{fieldNo}))
                value = argument.(Names{fieldNo});
            else
                value = [];
            end
            if ~isempty(value)
                options.(Names{fieldNo}) = value;
            end
        end
    end
    argNo = argNo + 1;
end

expectValue = false;
while argNo <= nargin
    argument = varargin{argNo};
    
    if ~expectValue
        if ~ischar(argument)
            error(message('bfmset:Invalid property name'));
        end
        
        argument = deblank(argument);
        
        index = find(strcmpi(argument,Names),1);
        if index >= 1
            expectValue = true;
        else
            error(message('bfmset:Invalid property name'));
        end
    else
        options.(Names{index}) = argument;
        expectValue = false;
    end
    argNo = argNo + 1;
end

if expectValue
    error(message('bfmset:No value for property'));
end


end

