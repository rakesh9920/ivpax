%% UPSAMPLE
rfc_c = zeromean(uni1_rfc);
upfactor = 8;
rfc_i = zeros(1,size(rfc_c,2)*upfactor,size(rfc_c,3));
for channel = 1:128
    rfc_i(1,:,channel) = interp(rfc_c(1,:,channel),upfactor);
end
rfc_i = bandpass(rfc_i,6.6,5.28,40*upfactor);
[numoflines numofsamples numofchannels] = size(rfc_i);
rfc_i = reshape(rfc_i,numoflines, numofsamples, numofchannels);
%% BEAMFORM
bfmopt = bfmset( ...
    'ArrayPitch', 300e-6, ...
    'CoherenceWeighting', false, ...
    'GaussApodization', true, ...
    'ChannelOmit', [], ... %us: 1 26 90 | pa: 97)
    'GaussWinAlpha', 1.5, ...
    'MinimumVariance', false, ...
    'MVSubarrayLength', 50, ...
    'RxApertureCurve', true, ...
    'RxCurveBtm', 100, ...
    'RxCurveMid', 68, ...%68
    'RxCurveTop', 10, ...%10
    'RxCurveVmid', 52, ...
    'RxMaxElements', 64, ... %64
    'RxCurveDepth', 0.055, ...
    'SampleFreq', 40e6*upfactor, ...
    'SoundSpeed', 1494, ...
    'Photoacoustic', true ...
    );

[bfm] = timebeamform(rfc_i, bfmopt);
%% CALCULATE GEOM DELAYS
env = envelope(bfm);
[val indy] = max(max(env));
[val indx] = max(env(:,indy));

pitch = 300e-6;
numofchannels = 128;
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;
%xs0 = indx % x sample location
%ys0 = 2037; % y sample location
x0 = indx*150e-6;
y0 = indy*1494/(40e6*upfactor);

geo = zeros(1,128);
for c = 1:128
   geo(c) = sqrt((array(c) - x0)^2 + y0^2)*40e6*upfactor/1494; 
end

geo = geo - min(geo);
%% CORRECT FOR GEOM DELAYS
rfc_p = zeros(size(rfc_i));
for channel = 1:128
    rfc_p(1,:,channel) = circshift(rfc_i(1,:,channel),[0 round(-geo(channel)) 0]);
end
%% CALCULATE PHASE ERROR
cutoff1 = 7200;
cutoff2 = 8600; 

xcv = zeros(1,127);
xcd = zeros(1,127);
xcd2 = zeros(1,127);
for channel = 2:127
    
    signal1 = squeeze(rfc_p(1,cutoff1:cutoff2,channel));
    signal2 = squeeze(rfc_p(1,cutoff1:cutoff2,channel+1));
    
    [val ind] = max(xcorr(signal1,signal2,'coeff'));
    xcv(channel) = val;
    xcd(channel) = ind - (cutoff2 - cutoff1 + 1);
    
    [val2 ind2] = max(rfc_i(1,cutoff1:cutoff2,channel));
    xcd2(channel) = ind2 + cutoff1;
end

delays(2:128) = cumsum(xcd,2);
%% CORRECTED IMAGE + PHASE ERROR OVERLAY
[v i] = max(rfc_p(1,:,2));
imagesc(squeeze(rfc_p)); hold on;
plot(-delays+i,'.');
%% PLOTS
%1: 64 to end
%2: 48 to 116
%3: full
%4: start to 118
%5: start to 59

d1 = delays1(64:end);
d2 = delays2(48:116);
d3 = delays3;
d4 = delays4(1:118);
d5 = delays5(1:59);

plot(delays1-mean(d1),'b.'); hold on;
plot(delays2-mean(d2),'r.');
plot(delays3-mean(d3),'g.');
plot(delays4-mean(d4),'k.');
plot(delays5-mean(d5),'c.');
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



