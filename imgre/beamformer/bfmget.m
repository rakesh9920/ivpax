function [value] = bfmget(options,property,default)
%BFMGET
% adapted from ODEGET

if nargin < 2
    message(error('bfmset: Not enough input arguments'));
end

if nargin < 3
    default = [];
end

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

index = find(strcmpi(property,Names),1);
if index >= 1
    value = options.(Names{index});
else
    error(message('bfmset:Invalid property name'));
end

if isempty(value)
    value = default;
end

end

