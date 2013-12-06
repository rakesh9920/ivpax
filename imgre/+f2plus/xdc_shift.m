function [ApertureOut] = xdc_shift(ApertureIn, Pos)
% Defines a new aperture that is a copy of ApertureIn shifted spatially by
% the vector Pos.

import fieldii.xdc_get
import fieldii.xdc_rectangles
import fieldii.xdc_triangles
import fieldii.xdc_focus_times
%import fieldii.xdc_free

if size(Pos,1) ~=3
    Pos = Pos.';
end

Info = xdc_get(ApertureIn, 'rect');

%xdc_free(ApertureIn);

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
    
    % pull info from xdc_get
    nElement = size(Info, 2);
    PhysElem = Info(1,:);
    Width = Info(3,:);
    Height = Info(4,:);
    Apod = Info(5,:);
    MathPos = Info(8:10,:);
    Corners = Info(11:22,:);
    Delays = xdc_get(ApertureIn, 'focus').';
    PhysPos = Info(24:26,:); 
    
    % determine physical element centers
    nPhysElement = max(PhysElem) + 1;
    PhysCenter = zeros(3, nPhysElement);
    
    for phys = 1:nPhysElement
       
        idx = find(PhysElem == (phys - 1), 1);
        PhysCenter(:,phys) = PhysPos(:, idx) + Pos;
    end

    % create rectangle definitions and define aperture
    Rect = zeros(19, nElement);
    Rect(1,:) = PhysElem  + 1;
    Rect(2:13,:) = bsxfun(@plus, Corners, repmat(Pos, 4, 1));
    Rect(14,:) = Apod;
    Rect(15,:) = Width;
    Rect(16,:) = Height;
    Rect(17:19,:) = bsxfun(@plus, MathPos, Pos);

    ApertureOut = xdc_rectangles(Rect.', PhysCenter.', [0 0 300]);
    xdc_focus_times(ApertureOut, Delays(:,1), Delays(:,2:end));
    
else
    
    nElement = size(Info, 2);
    PhysElem = Info(1,:);
    % MathElem = Info(2,:);
    Apod = Info(3,:);
    MathPos = Info(4:6,:);
    Corners = Info(7:15,:);
    
    % determine physical element centers
    nPhysElement = max(PhysElem) + 1;
    PhysCenter = zeros(3, nPhysElement);
    
    for phys = 1:nPhysElement
       
        idx = find(PhysElem == (phys - 1), 1);
        PhysCenter(:,phys) = MathPos(:, idx) + Pos;
    end
    
    Tri = zeros(11, nElement);
    
    Tri(1,:) = PhysElem + 1;
    Tri(2:10) = bsxfun(@plus, Corners, repmat(Pos, 3, 1));
    Tri(11,:) = Apod;
    
    ApertureOut = xdc_triangles(Tri.', PhysCenter.', [0 0 300]);
end

end