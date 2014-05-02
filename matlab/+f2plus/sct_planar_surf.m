function [] = sct_planar_surf(outDir)
%
%

import tools.advdouble
import tools.sqdistance

if outDir(end) ~= '/'
    outDir = cat(OutDir, '/');
end

N = 50000;
nScat = round(sqrt(N))^2;
Dim = [0.005 0.005];
ns = nScat/(Dim(1)*Dim(2));
%pi = 2.588e-12; % @ 0.5 m
%Ii = pi^2/(2*1000*1540);
%wref = 8.159980918415047e-18;
sigma = 0.316798267931919;

R = 0.5;
nPart = 12;

[PosX, PosY, PosZ] = ndgrid(linspace(0, Dim(1), sqrt(nScat)), ...
    linspace(0, Dim(2), sqrt(nScat)), 0);
Pos = bsxfun(@plus, [PosX(:) PosY(:) PosZ(:)], [-Dim(1)/2 -Dim(2)/2 R]);

Dist = sqrt(sqdistance(Pos.', [0; 0; 0]));

Amp = sqrt(pi.*Dist.^2./sigma./ns);
%Amp = ones(nScat, 1).*1.574539432315113/sqrt(ns);



partSize = ceil(nScat/nPart);

for part = 1:nPart
    
    front = (part - 1)*partSize + 1;
    if part == nPart
        back = nScat;
    else
        back = front + partSize - 1;
    end
    
    fileName = strcat(outDir, 'sct_', sprintf('%0.4d', part));
    
    SctMat = advdouble([Pos(front:back,:) Amp(front:back,:)]);
    SctMat.meta.fileNo = part;
    SctMat.meta.nScatTotal = nScat;
    
    save(fileName, 'SctMat');
end

end

