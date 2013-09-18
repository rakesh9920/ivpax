function [CMUT, Centers] = xdc_1d_cmut()
%
%

import fieldii.*

pitch = 245e-6;
numElements = 16;

Centers = -((numElements/2 - 1)*pitch + pitch/2):pitch:((numElements/2 - 1)*pitch + pitch/2);
Centers = [Centers; zeros(1, numElements); zeros(1, numElements)];

Rect = zeros(19, 180*16);

for el = 1:numElements
    
    Phys = xdc_2d_array(4, 45, 45e-6, 45e-6, 10e-6, 10e-6, ones(4, 45), 1, 1, [0 0 0]);
    
    PhysInfo = xdc_get(Phys, 'rect');
    
    xdc_free(Phys);
    
    elStart = 1 + (el - 1)*180;
    elEnd = elStart + 180 - 1;
    
    Rect(1,elStart:elEnd) = el; % physical element no.
    % rectangle coords
    Rect(2:13,elStart:elEnd) = PhysInfo(11:22,:) + repmat(Centers(:,el), 4, 180); 
    Rect(14,elStart:elEnd) = 1; % apodization
    Rect(15,elStart:elEnd) = PhysInfo(3,:); % math element width
    Rect(16,elStart:elEnd) = PhysInfo(4,:); % math element height
    % math element center
    Rect(17:19,elStart:elEnd) = PhysInfo(8:10,:) + repmat(Centers(:,el), 1, 180); 
end

CMUT = xdc_rectangles(Rect.', Centers.', [0 0 0]);



