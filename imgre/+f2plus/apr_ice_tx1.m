function [CMUT, Centers] = apr_ice_tx1()
%
%

import fieldii.*

% element: 4 elements per membranes, 10um between elements vertically (80um pitch),
% 10um between elements horizontally (80um pitch)
% membrane: 30x30um, 10um between membranes (40um pitch)


Phys = xdc_2d_array(2, 2, 30e-6, 30e-6, 10e-6, 10e-6, ones(2, 2), 1, 1, [0 0 0]);
PhysInfo = xdc_get(Phys, 'rect');
xdc_free(Phys);

for elem = 1:15
    
    elStart = 1 + (elem - 1)*4;
    elEnd = elStart + 4 - 1;
    
    
    Rect(1,elStart:elEnd) = el; % physical element no.
    % rectangle coords
    Rect(2:13,elStart:elEnd) = PhysInfo(11:22,:) + repmat(Centers(:,el), 4, 4);
    Rect(14,elStart:elEnd) = 1; % apodization
    Rect(15,elStart:elEnd) = PhysInfo(3,:); % math element width
    Rect(16,elStart:elEnd) = PhysInfo(4,:); % math element height
    % math element center
    Rect(17:19,elStart:elEnd) = PhysInfo(8:10,:) + repmat(Centers(:,el), 1, 4);
end

CMUT = xdc_rectangles(Rect.', Centers.', [0 0 300]);
end

function [Centers] = rectpts(iElement)

hPitch = 80e-6;
vPitch = 80e-6;
hLength = 70e-6;
vLength = 70e-6;
hSpace = hPitch - hLength;
vSpace = vPitch - vLength;
nElements = 15;

ref1 = [(-35.5*100e-6) + hPitch*(nElements + 1); 0; 0];
ref2 = [(35.5*100e-6) - hPitch*(nElements + 1); 0; 0];
ref3 = ref2;
ref4 = ref1;
%refPts = cat(2, ref1, ref2, ref3, ref4);

corner1 = ref1 + [-hPitch; vPitch; 0].*(iElement - 1);
corner2 = ref2 + [hPitch; vPitch; 0].*(iElement - 1);
corner3 = ref3 + [hPitch; -vPitch; 0].*(iElement - 1);
corner4 = ref4 + [-hPitch; -vPitch; 0].*(iElement - 1);
cornerPts = cat(2, corner1, corner2, corner3, corner4);

% (70e-6)*nh + 10e-6*(nh + 1) = abs(cornerPts(2,1) - cornerPts(1,1)) + 70e-6
hDist = abs(cornerPts(1,2) - cornerPts(1,1)) + hLength;
vDist = abs(cornerPts(2,3) - cornerPts(2,2)) + vLength;
nHElements = floor((hDist - hSpace)/(hSpace + hLength));
nVElements = floor((vDist - vSpace)/(vSpace + vLength));
%     nHElements = floor((abs(cornerPts(2,1) - cornerPts(1,1) + 70e-6-10e-6))/80e-6);
%     nVElements = floor((abs(cornerPts(2,3) - cornerPts(2,2) + 70e-6-10e-6))/80e-6);

Top = [linspace(cornerPts(1,1), cornerPts(1,2), nHElements);
    ones(1, nHElements).*cornerPts(2,1);
    zeros(1, nHElements)];

if iElement == 1
    
    Centers = Top;
else
    
    Right = [ones(1, nVElements).*cornerPts(1,2);
        linspace(cornerPts(2,2), cornerPts(2,3), nVElements);
        zeros(1, nVElements)];
    
    if size(Right,2) <= 2
        Right = [];
    else
        Right(:,1) = [];
        Right(:,end) = [];
    end
    
    Bottom = [linspace(cornerPts(1,3), cornerPts(1,4), nHElements);
        ones(1, nHElements).*cornerPts(2,3);
        zeros(1, nHElements)];
    
    Left = [ones(1, nVElements).*cornerPts(1,4);
        linspace(cornerPts(2,4), cornerPts(2,1), nVElements);
        zeros(1, nVElements)];
    if size(Left,2) <= 2
        Left = [];
    else
        Left(:,1) = [];
        Left(:,end) = [];
    end
    
    Centers = cat(2, Top, Right, Bottom, Left);
    %Centers = cat(2, Centers, cornerPts(:,3));
    %Centers = cat(2, Centers, Left(:,2:(end - 1)));
    %plot3(Centers(1,:), Centers(2,:), Centers(3,:), '-o');
    %plot3(cornerPts(1,:),cornerPts(2,:),cornerPts(3,:),'-ro');
    %hold on;
end

end


