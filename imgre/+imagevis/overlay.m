function [] = overlay(img1, img2, dyn1, dyn2)

[ny nx] = size(img1);
img1(img1 < -dyn1) = -dyn1;
iptsetpref('ImshowAxesVisible','on');

figure;
imshow(img2, [-dyn2 0],'XData',[0 nx.*150e-3],'YData',...
    [0 ny.*150e-3],'InitialMagnification', 200);

colormap('hot');
hold on

white = cat(3,ones(size(img1)),ones(size(img1)),ones(size(img1)));
%red = cat(3,ones(size(img2)),zeros(size(img2)),zeros(size(img2)));
R = imshow(white,'XData',[0 nx.*150e-3],'YData',...
    [0 ny.*150e-3],'InitialMagnification', 200);
set(R,'AlphaDataMapping','scaled');
set(R,'AlphaData',img1);

xlabel('lateral [mm]');
ylabel('axial [mm]');

end

