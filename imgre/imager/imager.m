function [img] = imager(bfrf,varargin)

% variable initialization
[nXPixels, samplesPerLine] = size(bfrf);
nYPixels = ceil(samplesPerLine*1540*25e-9/150e-6);

%nXPixels = 256*2;
%nYPixels = 278;

if nargin > 1
    dyn = varargin{1};
    
    %minVal = 10^(-dyn/20)*maxVal;
    
    %img = mat2gray(img, [-dyn 0]);
else
    dyn = 200;
    %img = mat2gray(transpose(bfrf));
end

img = double(bfrf.');
img = medfilt2(img,[2 2]);
maxVal = max(max(img));
%img = adapthisteq(img);
img = 20*log10(img./maxVal);
img(img < -200) = -200;
img2 = imresize(img, [nYPixels nXPixels]);
imtool(img2,'InitialMagnification',100,'DisplayRange',[-dyn 0]);

end