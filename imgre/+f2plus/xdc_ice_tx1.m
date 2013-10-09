function [CMUT, Centers] = xdc_ice_tx1()
%
%

import fieldii.*

% 70 H 24 V
% element: 4 membranes, element spacing 20um
% membrane: 35x35um, 10um spacing

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



