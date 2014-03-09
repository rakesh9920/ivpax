function [TargetMat] = sct_materialphantom1(outDir, targetDensity)
%SCT_MATERIALPHANTOM 

import tools.advdouble tools.saveadv

TargetMat = advdouble();

TargetMat.meta.StartFrame = 1;
TargetMat.meta.EndFrame = 1;
TargetMat.meta.FileID = 1;

Materials(1).Label = 'Background';
Materials(1).Bsc = [0 0];
Materials(2).Label = 'Tissue1';
Materials(2).Bsc = [0 0];
Materials(3).Label = 'Tissue2';
Materials(3).Bsc = [0 0];


% assign target locations and materials

Dim = [0.03 0.01 0.04];

nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity);

TargetPos = bsxfun(@minus, [rand(nTargets, 1).*Dim(1) rand(nTargets, 1).*Dim(2) ...
    rand(nTargets, 1).*Dim(3)], [Dim(1)/2 Dim(2)/2 0]);
TargetAmp = ones(nTargets, 1);

TargetAmp(incircle(TargetPos, [0.003 0 0.005], 0.0005)) = 2;
TargetAmp(incircle(TargetPos, [0.003 0 0.015], 0.0015)) = 2;
TargetAmp(incircle(TargetPos, [0.003 0 0.025], 0.0025)) = 2;
TargetAmp(incircle(TargetPos, [0.003 0 0.035], 0.003)) = 2;
TargetAmp(incircle(TargetPos, [-0.009 0 0.005], 0.003)) = 2;
TargetAmp(incircle(TargetPos, [-0.009 0 0.015], 0.0025)) = 2;
TargetAmp(incircle(TargetPos, [-0.009 0 0.025], 0.0015)) = 2;
TargetAmp(incircle(TargetPos, [-0.009 0 0.035], 0.0005)) = 2;
TargetAmp(incircle(TargetPos, [-0.003 0 0.005], 0.0005)) = 3;
TargetAmp(incircle(TargetPos, [-0.003 0 0.015], 0.0015)) = 3;
TargetAmp(incircle(TargetPos, [-0.003 0 0.025], 0.0025)) = 3;
TargetAmp(incircle(TargetPos, [-0.003 0 0.035], 0.003)) = 3;
TargetAmp(incircle(TargetPos, [0.009 0 0.005], 0.003)) = 3;
TargetAmp(incircle(TargetPos, [0.009 0 0.015], 0.0025)) = 3;
TargetAmp(incircle(TargetPos, [0.009 0 0.025], 0.0015)) = 3;
TargetAmp(incircle(TargetPos, [0.009 0 0.035], 0.0005)) = 3;

TargetMat = advdouble([TargetPos TargetAmp]);
TargetMat.meta.FileID = 1;
TargetMat.meta.StartFrame = 1;
TargetMat.meta.EndFrame = 1;
TargetMat.meta.Materials = Materials;

% split targetmat into separate files

% save to directory




end

function [Idx] = incircle(TargetPos, Center, radius)

import tools.sqdistance

Dist = sqrt(sqdistance(Center, TargetPos)).';

Idx = Dist <= radius;

end
