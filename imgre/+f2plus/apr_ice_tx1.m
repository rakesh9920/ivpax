function [CMUT, Centers] = apr_ice_tx1()
%
%

import fieldii.*

% element: 4 elements per membranes, 10um between elements vertically (80um pitch), 
% 10um between elements horizontally (80um pitch)
% membrane: 30x30um, 10um between membranes (40um pitch)

pitch = 100e-6;

H_x = repmat((-35*pitch + pitch/2):pitch:(35*pitch - pitch/2), 1, 24);
H_y = repmat((12*pitch - pitch/2):-pitch:(-12*pitch + pitch/2), 70, 1);
H_y = H_y(:).';
H_z = zeros(1, 1680);

Centers = [H_x; H_y; H_z];

Rect = zeros(19, 1680*4);

Phys = xdc_2d_array(2, 2, 35e-6, 35e-6, 10e-6, 10e-6, ones(2, 2), 1, 1, [0 0 0]);
PhysInfo = xdc_get(Phys, 'rect');
xdc_free(Phys);

for el = 1:1680
    
    elStart = 1 + (el - 1)*4;
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

function [] = rectpts(num)

num = 5;
hpitch = 80e-6;
vpitch = 80e-6;

for num = 2:15

ref1 = [(-35.5*100e-6) + hpitch*16; 0; 0];
ref2 = [(35.5*100e-6) - hpitch*16; 0; 0];
ref3 = ref2;
ref4 = ref1;
refpts = cat(2, ref1, ref2, ref3, ref4);

corner1 = ref1 + [-hpitch; vpitch; 0].*(num - 1);
corner2 = ref2 + [hpitch; vpitch; 0].*(num - 1);
corner3 = ref3 + [hpitch; -vpitch; 0].*(num - 1);
corner4 = ref4 + [-hpitch; -vpitch; 0].*(num - 1);
cornerpts = cat(2, corner1, corner2, corner3, corner4);

% (70e-6)*nh + 10e-6*(nh + 1) = abs(cornerpts(2,1) - cornerpts(1,1)) + 70e-6
% 
nh = floor((abs(cornerpts(2,1)-cornerpts(1,1)+70e-6-10e-6))/80e-6);
nv = floor((abs(cornerpts(2,3)-cornerpts(2,2)+70e-6-10e-6))/80e-6);
% 
pts = [linspace(cornerpts(1,1), cornerpts(1,2), nh); ones(1, nh).*cornerpts(2,1); zeros(1, nh)];

tmp = [ones(1, nv).*cornerpts(1,2); linspace(cornerpts(2,2), cornerpts(2,3), nv); zeros(1, nv)];
if size(tmp,2) < 2
    pts = cat(2, pts, cornerpts(:,3));
else
    pts = cat(2, pts, tmp(:,2:end));
end

tmp = [linspace(cornerpts(1,3), cornerpts(1,4), nh); ones(1, nh).*cornerpts(2,3); zeros(1, nh)];
pts = cat(2, pts, tmp(:,2:end));

tmp = [ones(1, nv).*cornerpts(1,4); linspace(cornerpts(2,4), cornerpts(2,1), nv); zeros(1, nv)];
if size(tmp,2) < 2
    
else
    pts = cat(2, pts, tmp(:,2:(end - 1)));
end


plot3(pts(1,:), pts(2,:), pts(3,:), '-o');
%plot3(cornerpts(1,:),cornerpts(2,:),cornerpts(3,:),'-ro');
hold on;
end

end


