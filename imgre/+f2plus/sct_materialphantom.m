function [TargetMat] = sct_materialphantom(outDir)
%SCT_MATERIALPHANTOM 

import tools.advdouble tools.saveadv

TargetMat = advdouble();



TargetMat.meta.StartFrame = 1;
TargetMat.meta.EndFrame = 1;
TargetMat.meta.FileID = 1;

Materials(1).Label = 'Blood1';
Materials(1).Bsc = [0 0];
Materials(2).Label = 'Blood2';
Materials(1).Bsc = [0 0];
Materials(3).Label = 'Tissue1';
Materials(1).Bsc = [0 0];
Materials(4).Label = 'Tissue2';
Materials(1).Bsc = [0 0];

% assign target locations and materials

% split targetmat into separate files

% save to directory




end

