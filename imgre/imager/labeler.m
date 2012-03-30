function [] = labeler(img, dyn, cmap)

[ny nx] = size(img);
iptsetpref('ImshowAxesVisible','on');

imshow(img, [-dyn 0],'XData',[0 nx.*150e-3],'YData',...
    [0 ny.*150e-3],'InitialMagnification',200);

xlabel('lateral [mm]');
ylabel('axial [mm]');
colormap(cmap);

end

