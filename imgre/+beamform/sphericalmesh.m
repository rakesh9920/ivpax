function [varargout] = sphericalmesh(rvg, tvg, pvg, org, section, nSection, sliceDim)
%SPHERICALMESH Creates a spherical mesh and subdivides the mesh into sections
%along the specified dimension.  Spherical coordinates are defined with
%theta (tvg) as the azimuth angle and phi (pvg) as the polar angle.

dimSize = [numel(rvg) numel(tvg) numel(pvg)];

slicesPerSection = ceil(dimSize(sliceDim)/nSection);

frontidx = (section - 1)*slicesPerSection + 1;
if section == nSection
    backidx = dimSize(sliceDim);
else
    backidx = frontidx + slicesPerSection - 1;
end

switch sliceDim
    case 1
        [R, Theta, Phi] = meshgrid(rvg(frontidx:backidx), tvg, pvg);
    case 2
        [R, Theta, Phi] = meshgrid(rvg, tvg(frontidx:backidx), pvg);
    case 3
        [R, Theta, Phi] = meshgrid(rvg, tvg, pvg(frontidx:backidx));
    otherwise
        error('invalid slice dimension');
end

X = R.*sin(Phi).*cos(Theta);
Y = R.*sin(Phi).*sin(Theta);
Z = R.*cos(Phi);

X = X(:) + org(1);
Y = Y(:) + org(2);
Z = Z(:) + org(3);

switch nargout
    case 2
        varargout{1} = X;
        varargout{2} = Y;
    case 3
        varargout{1} = X;
        varargout{2} = Y;
        varargout{3} = Z;
    otherwise
        varargout{1} = [X Y Z];
end

end

