function [img2 ref] = imager(bfrf,varargin)

% variable initialization
[nXPixels, samplesPerLine] = size(bfrf);
if nXPixels == 128
    nYPixels = ceil(samplesPerLine*1494*25e-9/300e-6);
elseif nXPixels == 256
    nYPixels = ceil(samplesPerLine*1481*25e-9/150e-6);
end

if nargin > 1
    dyn = varargin{1}; 
else
    dyn = 200;
end

img = double(bfrf.');
img = medfilt2(img,[2 2]);

if nargin > 2
    ref = varargin{2};
else
    ref = max(max(img));
end

img = 20*log10(img./ref);
img(img < -200) = -200;
img2 = imresize(img, [nYPixels nXPixels]);
imtool(img2,'InitialMagnification',200,'DisplayRange',[-dyn 0]);

end