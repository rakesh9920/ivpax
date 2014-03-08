function [Pulse] = gausspulse(fc, bw, fs, varargin)
%GAUSSFILT Provides a Gaussian time-domain pulse with the desired center
%frequency (fc) and half-power bandwidth (bw) for the sample frequency (fs).

Parser = inputParser;
Parser.KeepUnmatched = true;
Parser.addOptional('PulseType', 'Bipolar');

Parser.parse(varargin{:});
Prms = Parser.Results;
pulseType = Prms.PulseType;

sigma = fs/pi/bw*sqrt(2*log(sqrt(2)));

nSamples = round(2*sqrt(-2*log(0.01))*sigma);
samples = -(nSamples - 1)/2:(nSamples - 1)/2;

Win = exp(-1/(2*sigma^2).*samples.^2);

switch pulseType
    case 'unipolar'
        Pulse = cos(2*pi*fc*(samples./fs)).*Win;
    otherwise
        Pulse = sin(2*pi*fc*(samples./fs)).*Win;
end

end

