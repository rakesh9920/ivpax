function [] = labeler(ImgMat, dynRange, cMap)

[height width] = size(ImgMat);

iptsetpref('ImshowAxesVisible', 'on');

imshow(ImgMat, [-dynRange 0],'XData',[0 width.*75e-3],'YData',...
    [0 height.*75e-3],'InitialMagnification',200);

xlabel('lateral [mm]');
ylabel('axial [mm]');
colormap(cMap);

end

