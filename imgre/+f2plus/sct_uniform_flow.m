%
%


global SOUND_SPEED CENTER_FREQUENCY PULSE_REPITITION_RATE
SOUND_SPEED = 1540;    %  Ultrasound propagation velocity [m/s]
CENTER_FREQUENCY = 6e6;    %  Center frequency of transducer  [Hz]
PULSE_REPITITION_RATE = 2000;

RangeX = [-0.01 0.01];    %  x range for the scatterers  [m]
RangeY = [-0.0015 0.0015];     %  y range for the scatterers  [m]
RangeZ = [0 0.01];     %  z range for the scatterers  [m]

wavelength = SOUND_SPEED/CENTER_FREQUENCY;
nScatterer = 5*round((RangeX(2) - RangeX(1))*(RangeY(2) - RangeY(1))*...
    (RangeZ(2) - RangeZ(1))/wavelength^3);

%  Generate the coordinates and amplitude
%  Coordinates are rectangular within the range.
%  The amplitude has a Gaussian distribution.

PosX = (RangeX(2) - RangeX(1)).*rand(nScatterer, 1) - sum(RangeX)/2;
PosY = (RangeY(2) - RangeY(1)).*rand(nScatterer, 1) - sum(RangeY)/2;
PosZ = (RangeZ(2) - RangeZ(1)).*rand(nScatterer, 1) - sum(RangeZ)/2;

Pos = [PosX PosY PosZ];

%  Assign an amplitude and a velocity for each scatterer

Vel = [zeros(nScatterer, 1) zeros(nScatterer, 1) ones(nScatterer, 1)].*0.05;
Amp = randn(nScatterer, 1);

outDir = './data/sct/';
save(strcat(outDir, 'SCT', sprintf('%0.4d', 0)), 'Pos', 'Amp');

InitPos = Pos;
for frame = 1:9
    
    Pos = InitPos + Vel./PULSE_REPITITION_RATE.*frame;
    save(strcat(outDir, 'SCT', sprintf('%0.4d', frame)), 'Pos', 'Amp');
end

