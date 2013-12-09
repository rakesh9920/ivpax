function [] = sct_uniform_flow(outPath, targetRange, targetAmp, targetDensity, ...
    flowVelocity, nFrame)
%
%

import tools.advdouble
import tools.saveadv

if isempty(outPath)
    outPath = uigetdir('','Select an output directory');
end

if outPath(end) == '/'
    outPath(end) = [];
end

global PULSE_REPITITION_RATE
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 2000;
end

RangeX = targetRange(1:2);
RangeY = targetRange(3:4);
RangeZ = targetRange(5:6);

% RangeX = [-0.01 0.01];    %  x range for the scatterers  [m]
% RangeY = [-0.0005 0.0005];     %  y range for the scatterers  [m]
% RangeZ = [0.001 0.01];     %  z range for the scatterers  [m]

Vol = (RangeX(2) - RangeX(1))*(RangeY(2) - RangeY(1))*(RangeZ(2) - RangeZ(1));
nTarget = round(Vol*targetDensity);

% wavelength = SOUND_SPEED/CENTER_FREQUENCY;
% nScatterer = 2*round((RangeX(2) - RangeX(1))*(RangeY(2) - RangeY(1))*...
%     (RangeZ(2) - RangeZ(1))/wavelength^3);

InitPosX = (RangeX(2) - RangeX(1)).*rand(nTarget, 1) - ...
    (RangeX(2) - RangeX(1))/2 + sum(RangeX)/2;
InitPosY = (RangeY(2) - RangeY(1)).*rand(nTarget, 1) - ...
    (RangeY(2) - RangeY(1))/2 + sum(RangeY)/2;
InitPosZ = (RangeZ(2) - RangeZ(1)).*rand(nTarget, 1) - ...
    (RangeZ(2) - RangeZ(1))/2 + sum(RangeZ)/2;
InitPos = [InitPosX InitPosY InitPosZ];

%  Assign an amplitude and a velocity for each scatterer

Vel = [zeros(nTarget, 1) zeros(nTarget, 1) ones(nTarget, 1)].*flowVelocity;
Amp = ones(nTarget, 1).*targetAmp;

for frame = 1:nFrame
    
    Pos = bsxfun(@plus, InitPos, Vel./PULSE_REPITITION_RATE.*(frame - 1));
    TargetMat = advdouble([Pos Amp],{'target'});
    TargetMat.meta.frameNumber = frame;
    TargetMat.meta.fileNumber = frame;
    TargetMat.meta.numberOfTargets = nTarget;
    
    outFile = strcat(outPath, '\', 'sct_', sprintf('%0.4d', frame));
    saveadv(outFile, TargetMat);
end

