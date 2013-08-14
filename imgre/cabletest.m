

import ultrasonix.*

rfc = zeros(2000, 128, 16);
for ch = 0:15
    dirname = ['d:/data/ch' num2str(ch) '/'];
    [~,rf] = readDAQ(dirname, ones(1,128), 1, true);
    rfc(:,:,ch+1) = rf;
end
%%
for ch = 0:15
   imagesc(rfc(:,:,ch+1), [-500 500]); 
   title(num2str(ch));
   colorbar;
   pause
end
