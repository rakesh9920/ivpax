function [mesh] = polarmesh(radii, angles, gridres)

rmin = radii(1);
rmax = radii(2);
amin = angles(1);
amax = angles(2);

%cand = [rmin*amin rmax*amin rmin*amax rmax*amax];
xcand = [rmin.*cos([amin amax]) rmax.*cos([amin amax])];
ycand = [rmin.*sin([amin amax]) rmax.*sin([amin amax])];

rads = [pi/2 pi 3*pi/2 2*pi];
%extrema = [(rads(rads >= amin & rads <= amax)).*rmin ...
%(rads(rads >= amin & rads <= amax)).*rmax]
xextrema = [rmin.*cos(rads(rads >= amin & rads <= amax)) ...
            rmax.*cos(rads(rads >= amin & rads <= amax))];
yextrema = [rmin.*sin(rads(rads >= amin & rads <= amax)) ...
            rmax.*sin(rads(rads >= amin & rads <= amax))];
    
%cand = [cand extrema];
xcand = [xcand xextrema];
ycand = [ycand yextrema];

%xcand = cos(cand);
%ycand = sin(cand);

xmax = max(xcand);
xmin = min(xcand);
ymax = max(ycand);
ymin = min(ycand);

[meshx meshy] = meshgrid(xmin:gridres:xmax, ymin:gridres:ymax);
%meshx = xmin:gridres:xmax;
%meshy = ymin:gridres:ymax;

radius = meshx.^2 + meshy.^2;
meshx(radius > rmax^2 | radius < rmin^2) = [];
meshy(radius > rmax^2 | radius < rmin^2) = [];

theta = atan2(meshy,meshx);
theta(theta < 0) = theta(theta < 0) + 2*pi;
meshx(theta > amax | theta < amin) = [];
meshy(theta > amax | theta < amin) = [];

meshx = reshape(meshx, 1, size(meshx,1)*size(meshx,2));
meshy = reshape(meshy, 1, size(meshy,1)*size(meshy,2));

mesh = [meshx; meshy; zeros(1,length(meshx))];

end

