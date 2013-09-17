function [ImgMat] = imager(BfMat, dynRange, varargin)
% envelope detect, compression, resize, smoothing
% nxpixels, nypixels, pitch

import imager.envelope

% read in optional arguments
if nargin > 2
    if isa(varargin{1}, 'containers.Map')
        map = varargin{1};
    else
        keys = varargin(1:2:end);
        values = varargin(2:2:end);
        map = containers.Map(keys, values);
    end
else
    map = containers.Map;
end

if isKey(map, 'pxwidth')
    pxwidth = map('pxwidth');
else
    pxwidth = 150e-6;
end
if isKey(map, 'pxheight')
    pxheight = map('pxheight');
else
    pxheight = false;
end
if isKey(map, 'cmap')
    cmap = map('cmap');
else
    cmap = 'jet';
end
if isKey(map, 'label')
    label = map('label');
else
    label = false;
end

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

[nLine, nSample] = size(BfMat);

% calculate image width and height based on pixel sizes
if ~pxheight
    pxheight = pxwidth; % square pixels
end

width = nLine;
height = round(nSample/SAMPLE_FREQUENCY*SOUND_SPEED/2/pxheight);

% envelope detection and median filtering
ImgMat = envelope(double(BfMat));
%ImgMat = medfilt2(ImgMat,[2 2]);

% compression
ref = max(max(ImgMat));
ImgMat = 20*log10(ImgMat./ref);
ImgMat(ImgMat < -200) = -200; % cap DR to -200
ImgMat = transpose(imresize(ImgMat, [width height]));

% display
if nargout < 1
    if label
        
        iptsetpref('ImshowAxesVisible', 'on');
        
        imshow(ImgMat, [-dynRange 0],'XData',[0 width*pxwidth*1000],'YData',...
            [0 height*pxheight*1000],'InitialMagnification',200);
        
        colormap(cmap);
        xlabel('lateral [mm]');
        ylabel('axial [mm]');
        axis image 
    else
        
        imtool(ImgMat, 'InitialMagnification', 200, 'DisplayRange', [-dynRange 0]);
    end
    
    
end


end