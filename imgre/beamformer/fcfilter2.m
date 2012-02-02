function [rfc_fc] = fcfilter2(rfc)

fir94 = [5 5 -18 -22 32 54 -34 -89 14 104 14 -89 -34 54 32 -22 -18 5 5];
fir84 = [2 -10 -18 10 50 21 -64 -75 31 102 31 -75 -64 21 50 10 -18 -10 2];
fir64 = [4 8 3 -9 -20 -15 10 36 34 0 -43 -54 -19 37 63 37 -19 -54 -43 0 34 36 10 -15 -20 -9 3 8 4];

fir94 = fir94./sqrt(sum(fir94.^2));
fir84 = fir84./sqrt(sum(fir84.^2));
fir64 = fir64./sqrt(sum(fir64.^2));

[numoflines numofsamples numofchannels] = size(rfc);
rfc_fc = zeros(numoflines, numofsamples, numofchannels, class(rfc));

prog = progress(0,0,'Filtering');
for line = 1:numoflines
    
    progress(line/numoflines,0,'Filtering',prog);
    
    for channel = 1:numofchannels
        
        sig1 = filter(fir94,1,double(rfc(line,:,channel)));
        sig2 = filter(fir84,1,double(rfc(line,:,channel)));
        sig3 = filter(fir64,1,double(rfc(line,:,channel)));
        rfc_fc(line,:,channel) = (1/3).*(sig1 + sig2 + sig3);
    end
end

end

