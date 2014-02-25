function [A] = xdc_area(Aperture)
%XDC_AREA Returns the total area of the specified aperture.

import fieldii.xdc_get

Info = xdc_get(Aperture, 'rect');
A = [];

if ~isempty(Info)
    
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
    
    Width = Info(3,:);
    Height = Info(4,:);
    
    A = sum(Width.*Height);
else
    
    Info = xdc_get(Aperture, 'tri');
    
    if ~isempty(Info)
        
        Corner1 = Info(7:9,:);
        Corner2 = Info(10:12,:);
        Corner3 = Info(13:15,:);
        
        % calculate triangle area using Heron's formula
        a = sqrt(sum((Corner2 - Corner1).^2, 1));
        b = sqrt(sum((Corner3 - Corner2).^2, 1));
        c = sqrt(sum((Corner1 - Corner3).^2, 1));
        
        p = (a + b + c)/2;
        
        A = sum(sqrt(p.*(p - a).*(p - b).*(p - c)));
    end
end





end

