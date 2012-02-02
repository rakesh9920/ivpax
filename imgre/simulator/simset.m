function [options] = simset(varargin)
%SIMSET creates/modifies bfm options structure
% adapted from ODESET

if (nargin == 0) && (nargout == 0)
    fprintf('          Amplitude: [ positive scalar in V ]\n');
    fprintf('          Frequency: [ positive scalar in Hz ]\n');
    fprintf('GaussFractBandwidth: [ positive scalar ]\n');
    fprintf('           NoiseSnr: [ positive scalar in dB ]\n');
    fprintf('          PulseType: [ string ]\n');
    fprintf('         SampleFreq: [ positive scalar in Hz ]\n');
    fprintf('         SensorGeom: [ Nx3 matrix in m ]\n');
    fprintf('         SoundSpeed: [ positive scalar in m/s ]\n');
    fprintf('         SourceGeom: [ Nx3 matrix in m ]\n');
    fprintf(' SquareWindowLength: [ positive scalar in s ]\n');
    fprintf('          TimeDelay: [ scalar in s ]\n');
    fprintf('         TimeLength: [ positive scalar in s ]\n');
    return;
end

% Define options
Names = {
    'Amplitude'
    'Frequency'
    'GaussFractBandwidth'
    'NoiseSnr'
    'PulseType'
    'SampleFreq'
    'SensorGeom'
    'SoundSpeed'
    'SourceGeom'
    'SquareWindowLength'
    'TimeDelay'
    'TimeLength'
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
            error(message('simset:No property names or structures'));
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
            error(message('simset:Invalid property name'));
        end
        
        argument = deblank(argument);
        
        index = find(strcmpi(argument,Names),1);
        if index >= 1
            expectValue = true;
        else
            error(message('simset:Invalid property name'));
        end  
    else
        options.(Names{index}) = argument;
        expectValue = false;    
    end
    argNo = argNo + 1;
end

if expectValue
    error(message('simset:No value for property'));
end


end

