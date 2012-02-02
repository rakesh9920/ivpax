function [] = overlay(img1, img2,cmap)

figure;
imshow(img1,'InitialMag',200,'Border','tight');
colormap(cmap);
hold on
white = cat(3,ones(size(img2)),ones(size(img2)),ones(size(img2)));
red = cat(3,ones(size(img2)),zeros(size(img2)),zeros(size(img2)));
R = imshow(white);
set(R,'AlphaData',img2);

end

