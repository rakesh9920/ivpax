function [TargetMat] = sct_miniphantom1(targetDensity, outDir)
%SCT_MATERIALPHANTOM

import tools.advdouble tools.saveadv tools.dirprompt

outDir = dirprompt(outDir);

nfft = 2^13;
% Bsc = zeros(1, nfft);
% Bsc(1:nfft/2+1) = linspace(10, 0, nfft/2+1);
% Bsc(nfft/2+1:end) = Bsc(nfft/2:-1:1);

Materials(1).Label = 'Background';
Materials(1).Bsc = ones(1, nfft).*1;
Materials(2).Label = 'Echogenic';
Materials(2).Bsc = ones(1, nfft).*31;
Materials(3).Label = 'Anechoic';
Materials(3).Bsc = ones(1, nfft)./31;

% assign target locations and materials

Dim = [0.02 0.01 0.014];

nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity);

TargetPos = bsxfun(@minus, [rand(nTargets, 1).*Dim(1) rand(nTargets, 1).*Dim(2) ...
    rand(nTargets, 1).*Dim(3)], [Dim(1)/2 Dim(2)/2 (-0.02+Dim(3)/2)]);
TargetAmp = ones(nTargets, 1);

TargetAmp(insphere(TargetPos, [0.0045 0 0.024], 0.002)) = 2;
TargetAmp(insphere(TargetPos, [-0.0045 0 0.016], 0.002)) = 2;
TargetAmp(insphere(TargetPos, [0.0045 0 0.016], 0.002)) = 3;
TargetAmp(insphere(TargetPos, [-0.0045 0 0.024], 0.002)) = 3;

TargetMat = advdouble([TargetPos TargetAmp]);
TargetMat.label = {'target', 'info'};
TargetMat.meta.StartFrame = 1;
TargetMat.meta.EndFrame = 1;
TargetMat.meta.Materials = Materials;

% split targetmat into separate files

% TargetMat.meta.FileID = 1;
% TargetMat.meta.NumberOfTargets = size(TargetMat, 1);
% 
% outPath = fullfile(outDir, ['sct_' sprintf('%0.4d', 1)]);
% saveadv(outPath, TargetMat);

nFiles = 1;
nTargetsPerFile = floor(nTargets/nFiles);

for file = 1:nFiles

    frontidx = (file - 1)*nTargetsPerFile + 1;
    backidx = file*nTargetsPerFile;

    if file == nFiles
        TargetMatOut = TargetMat(frontidx:end,:);
    else
        TargetMatOut = TargetMat(frontidx:backidx,:);
    end

    TargetMatOut.meta.FileID = file;
    TargetMatOut.meta.NumberOfTargets = size(TargetMatOut, 1);

    outPath = fullfile(outDir, ['sct_' sprintf('%0.4d', file)]);
    saveadv(outPath, TargetMatOut);
end

end

function [Idx] = insphere(TargetPos, Center, radius)

import tools.sqdistance

Dist = sqrt(sqdistance(Center, TargetPos)).';

Idx = Dist <= radius;

end
