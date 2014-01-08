function [] = sct_uniform_flow(outDir, targetRange, targetAmp, targetDensity, ...
    flowVelocity, nFrame)
%SCT_UNIFORM_FLOW Creates sct files for a uniform flow field.

import tools.advdouble tools.saveadv tools.dirprompt

outDir = dirprompt(outDir);

global PULSE_REPITITION_RATE
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 2000;
end

RangeX = targetRange(1:2);
RangeY = targetRange(3:4);
RangeZ = targetRange(5:6);

Vol = (RangeX(2) - RangeX(1))*(RangeY(2) - RangeY(1))*(RangeZ(2) - RangeZ(1));
nTarget = round(Vol*targetDensity);

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
    TargetMat = advdouble([Pos Amp],{'target', 'info'});
    TargetMat.meta.fileNumber = frame;
    TargetMat.meta.startFrame = frame;
    TargetMat.meta.endFrame = frame;
    TargetMat.meta.numberOfTargets = nTarget;
    
    outPath = fullfile(outDir, ['sct_' sprintf('%0.4d', frame)]);
    saveadv(outPath, TargetMat);
end

