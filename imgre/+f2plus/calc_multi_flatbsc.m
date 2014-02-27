function [RfMat, startTime] = calc_multi_flatbsc(Tx, Rx, Points, bsc, varargin)
%CALC_SCAT_MULTI_BSC Runs calc_scat_multi in Field II with the target
%amplitude set to match the given backscattering coefficient with a flat
%spectral response.  The received array's impulse response must be modified
%accordingly for correct results.

import fieldii.calc_scat_multi

Parser = inputParser();
Parser.KeepUnmatched = true;
Parser.addOptional('SoundSpeed', 1540);
Parser.addOptional('FluidDensity', 1000);
Parser.addOptional('Area', 1);
Parser.addOptional('TargetDensity', 10*1000^3);

Parser.parse(varargin{:});
Prms = Parser.Results;
SoundSpeed = Prms.SoundSpeed;
FluidDensity = Prms.FluidDensity;
Area = Prms.Area;
TargetDensity = Prms.TargetDensity;

nPoints = size(Points, 1);

phi = sqrt(bsc/TargetDensity);
amp = 2*pi*phi/(FluidDensity*SoundSpeed*Area);

[RfMat, startTime] = calc_scat_multi(Tx, Rx, Points, ones(nPoints, 1).*amp);

end

