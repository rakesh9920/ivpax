%%
rfc_c = zeromean(rfc_noabb);
rfc_i = zeros(size(rfc_c,1)*4,size(rfc_c,2));
for channel = 1:128
    rfc_i(:,channel) = interp(rfc_c(:,channel),4);
end
rfc_i = bandpass(rfc_i',6.6,5.28,40*4)';
rfc_i = reshape(rfc_i,1,6480,128);

%%
cutoff1 = 3800; %3840
cutoff2 = 5200; %5120

xcv = zeros(1,127);
xcd = zeros(1,127);
for channel = 2:127
    
    signal1 = squeeze(rfc_p(1,cutoff1:cutoff2,channel));
    signal2 = squeeze(rfc_p(1,cutoff1:cutoff2,channel+1));
    
    [val ind] = max(xcorr(signal1,signal2,'coeff'));
    xcv(channel) = val;
    xcd(channel) = ind - (cutoff2 - cutoff1 + 1);
end

delays(2:128) = cumsum(xcd,2);
%% no ab
delays(1) = -24;
delays(26) = 528;
p = polyfit(1:128,delays,20);
err = delays-polyval(p,1:128);
%% with ab
delays(1) = delays(2) - (delays(3)-delays(2));
delays(26) = delays(25) + (delays(27)-delays(25))/2;
p = polyfit(1:128,delays,20);
err = delays-polyval(p,1:128);
%%
rfc_p = zeros(size(rfc_i));
geo = polyval(p,1:128);
geo = geo - max(geo);
for channel = 1:128
    rfc_p(1,:,channel) = circshift(rfc_i(1,:,channel),[0 round(geo(channel)) 0]);
end
%%
ref = 71;
pitch = 300e-6;
numofchannels = 128;
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;
xs0 = 138; %141
ys0 = 2037; %1979
x0 = xs0*150e-6;
y0 = ys0*6.25e-9*1494;
%x0 = array(71);
%y0 = 3981*6.25e-9*1494/2;

geo = zeros(1,128);
for c = 1:128
   geo(c) = sqrt((array(c) - x0)^2 + y0^2)/6.25e-9/1494; 
end

geo = geo - min(geo);
%%
rfc_p = zeros(1,6480,128);
for c = 1:128
   rfc_p(1,:,c) = circshift(rfc_i(1,:,c),[0 -round(geo(c)-delays(c)) 0]); 
end
%%
rfc_p = zeros(1,6480,128);
for c = 1:128
   rfc_p(1,:,c) = circshift(rfc_i(1,:,c),[0 -round(-delays(c)) 0]); 
end




