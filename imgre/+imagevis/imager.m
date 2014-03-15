function [ImgMat] = imager(BfMat, dynRange, height, width)
%IMAGER envelope detect, compression, resize, smoothing
% nxpixels, nypixels, pitch

import imagevis.envelope

ImgMat = envelope(double(BfMat), 1);
%ImgMat = medfilt2(ImgMat,[2 2]);

% compression
ref = max(max(ImgMat));
ImgMat = 20*log10(ImgMat./ref);
ImgMat(ImgMat < -200) = -200; % cap DR to -200
ImgMat = imresize(ImgMat, [height width]);
label = true;
% display
if nargout < 1

    if label
        
        iptsetpref('ImshowAxesVisible', 'on');
        
        imshow(ImgMat, [-dynRange 0],'XData',[0 width*100e-6*1000],'YData',...
            [0 height*100e-6*1000],'InitialMagnification',200);
        colormap('gray');
        xlabel('lateral [mm]');
        ylabel('axial [mm]');
        axis image
    else
        
        imtool(ImgMat, 'InitialMagnification', 200, 'DisplayRange', [-dynRange 0]);
    end
end

end