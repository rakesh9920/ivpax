function [rfc] = test()

hd.frameSize = 216000;
hd.linesPerFrame = 100;
hd.totalParts = 1;
hd.focus = 0;
hd.beamformed = 1;

%rfc_avg = zeros(1,1080,7,'int16');
rfc = zeros(100,1080,128,'int16');
for f = 1:128
    filename = strcat('rfdata/t4_p',num2str(f),'.rf');
    rfc(:,:,f) = readrf(filename, hd);   
    clear filename header; 
end

end

function [rfout] = avg(rfin)

sum = zeros(1,1080,'int32');

for n = 1:100
    sum = sum + int32(rfin(n,:));
end

rfout = int16(sum./100);
end

