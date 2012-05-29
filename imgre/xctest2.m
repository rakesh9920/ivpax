%%
rfc_c = zeromean(rfc_abb);
rfc_i = zeros(size(rfc_c,1)*4,size(rfc_c,2));
for channel = 1:128
    rfc_i(:,channel) = interp(rfc_c(:,channel),4);
end
rfc_b = bandpass(rfc_i',6.6,5.28,40*4)';

%%
cutoff1 = 960*4;
cutoff2 = 1280*4;

xcv = zeros(1,127);
xcd = zeros(1,127);
for channel = 1:127
    
    signal1 = rfc_b(cutoff1:cutoff2,channel);
    signal2 = rfc_b(cutoff1:cutoff2,channel+1);
    
    [val ind] = max(xcorr(signal1,signal2,'coeff'));
    xcv(channel) = val;
    xcd(channel) = ind - (cutoff2 - cutoff1);
end

delays(2:128) = cumsum(xcd,2);

%% no ab
delays(1) = -166;
delays(26) = 409;
p = polyfit(1:128,delays,4);
err = delays-polyval(p,1:128);
%% with ab
delays(1) = delays(2) - (delays(3)-delays(2));
delays(26) = delays(25) + (delays(27)-delays(25))/2;
p = polyfit(1:128,delays,4);
err = delays-polyval(p,1:128);
%%
rfc_p = zeros(size(rfc_b));
geo = polyval(p,1:128);
for channel = 1:128
    rfc_p(:,channel) = circshift(rfc_b(:,channel),round(delays(channel)));
    %rfc_p(:,channel) = circshift(rfc_b(:,channel),round(geo(channel)));
end