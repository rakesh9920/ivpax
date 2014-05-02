function [nElement] = xdc_nmath(Aperture)
%XDC_NMATH Returns the number of mathematical elements in an aperture.

import fieldii.xdc_get;

Info = xdc_get(Aperture, 'rect');

nElement = [];

if ~isempty(Info)
    
    nElement = size(Info, 2);
else
    
    Info = xdc_get(Aperture, 'tri');
    
    if ~isempty(Info)
        
        nElement = size(Info, 2);
    end
end