function [Filt] = bsc2filt(Bsc, varargin)
%BSC2FILT

import sigproc.iffts sigproc.fftdiff

Parser = inputParser();
Parser.KeepUnmatched = true;
Parser.addOptional('SoundSpeed', 1540);
Parser.addOptional('FluidDensity', 1000);
Parser.addOptional('Area', 1);
Parser.addOptional('TargetDensity', 10*1000^3);
Parser.addOptional('SampleFrequency', 100e6);

Parser.parse(varargin{:});
Prms = Parser.Results;
c = Prms.SoundSpeed;
rho = Prms.FluidDensity;
SR = Prms.Area;
ns = Prms.TargetDensity;
fs = Prms.SampleFrequency;

[Bsc, perm, nshifts] = shiftdata(Bsc, []);

Phi = sqrt(abs(Bsc)./ns);
Amp = fftdiff(Phi, fs).*(2*pi/(rho*c*SR));
Filt = ifftshift(iffts(Amp, 'symmetric', fs));

Filt = unshiftdata(Filt, perm, nshifts);

end

