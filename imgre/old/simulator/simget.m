function [value] = simget(options,property,default)
%SIMGET
% adapted from ODEGET

if nargin < 2
    message(error('simget: Not enough input arguments'));
end

if nargin < 3
    default = [];
end

Names = {
    'Amplitude'
    'Frequency'
    'GaussFractBandwidth'
    'PulseType'
    'NoiseSnr'
    'SampleFreq'
    'SensorGeom'
    'SoundSpeed'
    'SourceGeom'
    'SquareWindowLength'
    'TimeDelay'
    'TimeLength'
    };
Names = deblank(Names);

index = find(strcmpi(property,Names),1);
if index >= 1
    value = options.(Names{index});
else
    error(message('simget:Invalid property name'));
end

if isempty(value)
   value = default; 
end

end

