function [Centers, Aperture] = apr_ice_rx()
% ICE receive configuration: 192 element ring with 100um pitch between
% elements.

% 72 H 24 V
% element: 4 membranes, 20um between elements
% membrane: 35x35um, 10um between membranes

pitch = 100e-6;

TR_x = (1:36).*pitch - pitch/2;
TR_y = ones(1,36).*(13*pitch - pitch/2);
R_x = ones(1,24).*(36*pitch - pitch/2);
R_y = (12*pitch - pitch/2):-pitch:(-12*pitch + pitch/2);
BR_x = fliplr(TR_x);
BR_y = -TR_y;
BL_x = -TR_x;
BL_y = -TR_y;
L_x = -R_x;
L_y = -R_y;
TL_x = fliplr(-TR_x);
TL_y = TR_y;
All_z = zeros(1,192);

Centers = zeros(3,192);
Centers(1,:) = [TR_x R_x BR_x BL_x L_x TL_x];
Centers(2,:) = [TR_y R_y BR_y BL_y L_y TL_y];
Centers(3,:) = All_z;

if nargout > 1
    
    import fieldii.xdc_free fieldii.xdc_get fieldii.xdc_rectangles 
    import fieldii.xdc_2d_array
    
    Rect = zeros(19, 4*192);
    
    Phys = xdc_2d_array(2, 2, 35e-6, 35e-6, 10e-6, 10e-6, ones(2, 2), 1, 1, [0 0 0]);
    PhysInfo = xdc_get(Phys, 'rect');
    xdc_free(Phys);
    
    for el = 1:192
        
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
    
    Aperture = xdc_rectangles(Rect.', Centers.', [0 0 300]);
end

Centers = Centers.';

