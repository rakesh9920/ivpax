function [amp] = sct_flatbsc(bsc, varargin)
%SCT_FLATBSC Returns the target amplitude required in Field II to match the
%given backscattering coefficient with a flat spectral response.  The
%received array's impulse response must be modified accordingly for
%correct results.

Parser = inputParser();
Parser.addOptional('SoundSpeed', 1540);
Parser.addOptional('FluidDensity', 1000);
Parser.addOptional('Area', 1);
Parser.addOptional('TargetDensity', 10*1000^3);

Prms = Parser.parse(varargin{:});
SoundSpeed = PrmsSoundSpeedc;
FluidDensity = Prms.FluidDensity;
Area = Prms.Area;
TargetDensity = Prms.TargetDensity;

phi = sqrt(bsc/TargetDensity);
amp = 2*pi*phi/(FluidDensity*SoundSpeed*Area);

end

