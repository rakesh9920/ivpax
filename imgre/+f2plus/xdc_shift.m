function [ApertureOut] = xdc_shift(ApertureIn, Pos)

import fieldii.xdc_get
import fieldii.xdc_free
import fieldii.xdc_rectangles
import fieldii.xdc_triangles

if size(Pos,1) ~=3
    Pos = Pos.';
end

Info = xdc_get(ApertureIn, 'rect');

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

    Rect = zeros(19, nElement);
    
    Rect(1,:) = PhysElem;
    Rect(2:13,:) = bsxfun(@plus, Corners, repmat(Pos, 4, 1));
    Rect(14,:) = Apod;
    Rect(15,:) = Width;
    Rect(16,:) = Height;
    Rect(17:19,:) = bsxfun(@plus, MathPos, Pos);

    ApertureOut = xdc_rectangles(Rect.', PhysCenter.', [0 0 0]);
    xdc_focus_times(ApertureOut, 0, Delays);
    
else
    
    
    nElement = size(Info, 2);
    PhysElem = Info(1,:);
    MathElem = Info(2,:);
    Apod = Info(3,:);
    MathPos = Info(4:6,:);
    Corners = Info(7:15,:);
    
    Tri = zeros(11, nElement);
    
    Tri(1,:) = PhysElem;
    Tri(2:10) = Corners;
    Tri(11,:) = Apod;
    
    ApertureOut = xdc_triangles(Info);
end

end