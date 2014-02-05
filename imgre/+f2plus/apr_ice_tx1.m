function [Centers, Aperture] = apr_ice_tx1()
% ICE transmit configuration #1: 15 defocused rectangular rings with 80um
% pitch between rings.

import fieldii.xdc_2d_array fieldii.xdc_get fieldii.xdc_free fieldii.xdc_rectangles

% element: 4 elements per membranes, 10um between elements vertically (80um pitch),
% 10um between elements horizontally (80um pitch)
% membrane: 30x30um, 10um between membranes (40um pitch)

Phys = xdc_2d_array(2, 2, 30e-6, 30e-6, 10e-6, 10e-6, ones(2, 2), 1, 1, [0 0 0]);
PhysInfo = xdc_get(Phys, 'rect');
xdc_free(Phys);

% Reference for xdc_get
% number of elements = size(Info, 2);
% physical element no. = Info(1,:);
% mathematical element no. = Info(2,:);
% element width = Info(3,:);
% element height = Info(4,:);
% apodization weight = Info(5,:);
% mathematical element center = Info(8:10,:);
% element corners = Info(11:22,:);
% delays = Info(23,:);
% physical element position = Info(24:26,:);
Rect = [];

%colors = [repmat([10 30], 1, 7) 10];
for elem = 1:15
    
    MathCenters = rectpts(elem);
    
    nMathElements = size(MathCenters, 2).*4;
    PhysRect = zeros(19, nMathElements);
    
    PhysRect(1,:) = elem; % physical element no.
    % rectangle coords
    PhysRect(2:13,:) = repmat(PhysInfo(11:22,:), [1 nMathElements/4]) + repmat(kron(MathCenters, [1 1 1 1]), [4 1]);
    PhysRect(14,:) = ones(1, nMathElements).*1;%colors(elem).*100;%.*rand*100; % apodization
    PhysRect(15,:) = repmat(PhysInfo(3,:), [1 nMathElements/4]); % math element width
    PhysRect(16,:) = repmat(PhysInfo(4,:), [1 nMathElements/4]); % math element height
    % math element center
    PhysRect(17:19,:) = repmat(PhysInfo(8:10,:), [1 nMathElements/4]) + kron(MathCenters, [1 1 1 1]);
    
    Rect = [Rect PhysRect];
end

Centers = zeros(15, 3);

Aperture = xdc_rectangles(Rect.', Centers, [0 0 300]);

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
nHCenters = floor(((ref2(1) - ref1(1)) + hPitch)/hPitch);

ref1 = [-(nHCenters - 1)*hPitch/2; 0; 0];
ref2 = [(nHCenters - 1)*hPitch/2; 0; 0];
ref3 = ref2;
ref4 = ref1;
%refPts = cat(2, ref1, ref2, ref3, ref4);

corner1 = ref1 + [-hPitch; vPitch; 0].*(iElement - 1);
corner2 = ref2 + [hPitch; vPitch; 0].*(iElement - 1);
corner3 = ref3 + [hPitch; -vPitch; 0].*(iElement - 1);
corner4 = ref4 + [-hPitch; -vPitch; 0].*(iElement - 1);
cornerPts = cat(2, corner1, corner2, corner3, corner4);

% (70e-6)*nh + 10e-6*(nh + 1) = abs(cornerPts(2,1) - cornerPts(1,1)) + 70e-6
hDist = abs(cornerPts(1,2) - cornerPts(1,1));
vDist = abs(cornerPts(2,3) - cornerPts(2,2));
nHElements = floor((hDist + hPitch)/hPitch);
nVElements = floor((vDist + vPitch)/vPitch);
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


