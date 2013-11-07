function [nElement] = xdc_nphys(Aperture)
%
%

import fieldii.xdc_get;

Info = xdc_get(Aperture, 'rect');

nElement = [];

if ~isempty(Info)
    
    nElement = Info(1,end) + 1;
    
else
    
    Info = xdc_get(Aperture, 'tri');
    
    if ~isempty(Info)
        
        nElement = Info(1,end) + 1;
    end
end