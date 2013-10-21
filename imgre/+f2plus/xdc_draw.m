function [] = xdc_draw(Aperture, varargin)
%
%

import fieldii.xdc_get;

if nargin > 1
    cmult = varargin{1};
else
    cmult = 1;
end

Info = xdc_get(Aperture, 'rect');

if ~isempty(Info)
    
    nElement = size(Info, 2);
    
    for elem = 1:nElement
        
        X = [Info(11,elem) Info(20,elem); Info(14,elem) Info(17,elem)];
        Y = [Info(12,elem) Info(21,elem); Info(15,elem) Info(18,elem)];
        Z = [Info(13,elem) Info(22,elem); Info(16,elem) Info(19,elem)];
        C = repmat(Info(5,elem), 2, 2).*cmult;
        
        surf(X, Y, Z, C);
        hold on;
    end
    
    Ax = axis;
    axMax = max(Ax(1:4));
    axMin = min(Ax(1:4));
    axis([axMin axMax axMin axMax Ax(5) Ax(6)]);
    xlabel('x [m]');
    ylabel('y [m]');
    zlabel('z [m]');
else
    
    Info = xdc_get(Aperture, 'tri');
    
    if ~isempty(Info)
        
        nElement = size(Info, 2);
        
        for elem = 1:nElement
            
            X = [Info(7,elem) Info(10,elem) Info(13,elem)];
            Y = [Info(8,elem) Info(11,elem) Info(14,elem)];
            Z = [Info(9,elem) Info(12,elem) Info(15,elem)];
            C = repmat(Info(5,elem), 1, 3);
            
            trisurf([1 2 3], X, Y, Z, C); colormap(cmap);
            hold on;
        end
        
        Ax = axis;
        axMax = max(Ax(1:4));
        axMin = min(Ax(1:4));
        axis([axMin axMax axMin axMax Ax(5) Ax(6)]);
        xlabel('x [m]');
        ylabel('y [m]');
        zlabel('z [m]');
    end
end