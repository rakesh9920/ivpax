function [TargetPos] = sct_spherical(rvg, tvg, pvg, org, targetDensity)
%SCT_SPHERICAL

Dim = 2.*[rvg(2) rvg(2) rvg(2)];

nTargets = round(Dim(1)*Dim(2)*Dim(3)*targetDensity);

TargetPos = bsxfun(@minus, [rand(nTargets,1).*Dim(1) rand(nTargets,1).*Dim(2) ...
    rand(nTargets,1).*Dim(3)], Dim./2);

R = sqrt(TargetPos(:,1).^2 + TargetPos(:,2).^2 + TargetPos(:,3).^2);

TargetPos(R < rvg(1) | R > rvg(2),:) = [];
R(R < rvg(1) | R > rvg(2),:) = [];

Theta = atan2(TargetPos(:,2), TargetPos(:,1));
Theta(Theta < 0) = Theta(Theta < 0) + 2*pi;

TargetPos(Theta < tvg(1) | Theta > tvg(2),:) = [];
R(Theta < tvg(1) | Theta > tvg(2),:) = [];

Phi = acos(TargetPos(:,3)./R);

TargetPos(Phi < pvg(1) | Phi > pvg(2),:) = [];

TargetPos = bsxfun(@plus, TargetPos, org);

end

