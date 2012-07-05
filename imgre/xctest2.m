%% FIND MAX FRAME
cutoff1 = 500;

e = abs(rfc(:,cutoff1:end,:));

[v indc] = max(max(max(e))); 
[v indy] = max(max(e(:,:,indc))); 
[v indx] = max(e(:,indy,indc));

indy = indy + cutoff1 - 1;
%% UPSAMPLE
rfc_c = zeromean(rfc(indx,:,:));
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
    'SoundSpeed', 1477, ...
    'Photoacoustic', true ...
    );

[bfm] = timebeamform(rfc_p, bfmopt);
%% CALCULATE GEOM DELAYS
env = envelope(bfm);
[val indy] = max(max(env));
[val indx] = max(env(:,indy));
wavespeed = 1477; %bfm.SoundSpeed

pitch = 300e-6;
numofchannels = 128;
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;
%xs0 = indx % x sample location
%ys0 = 2037; % y sample location
x0 = array(round(indx/2));%indx*150e-6;
y0 = indy*wavespeed/(40e6*upfactor);

geo = zeros(1,128);
for c = 1:128
   geo(c) = sqrt((array(c) - x0)^2 + y0^2)*40e6*upfactor/wavespeed; 
end

geo = geo - min(geo);
%% CORRECT FOR GEOM DELAYS
rfc_p = zeros(size(rfc_i));
for channel = 1:128
    rfc_p(1,:,channel) = circshift(rfc_i(1,:,channel),[0 round(-geo(channel)) 0]);
end
%% CALCULATE PHASE ERROR
cutoff1 = 8000;
cutoff2 = 9000; 

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

d1 = delays1; %10
d2 = delays2; %37
d3 = delays3; %56
d4 = delays4(27:end); %87
d5 = delays5(37:end); %118

plot(1:128,(d1-max(d1)).*3.125,'b.'); hold on;
plot(1:128,(d2-max(d2)).*3.125,'r.');
plot(1:128,(d3-max(d3)).*3.125,'g.');
plot(27:128,(d4-max(d4)).*3.125,'k.');
plot(37:128,(d5-max(d5)).*3.125,'c.');
%%
plot((speed1469 - speed1469(56)).*3.125,'.'); hold on;
plot((speed1474 - speed1474(56)).*3.125,'c.');
plot((speed1479 - speed1479(56)).*3.125,'r.');
plot((speed1484 - speed1484(56)).*3.125,'k.');
plot((speed1489 - speed1489(56)).*3.125,'y.');
legend('1469 m/s','1474 m/s','1479 m/s','1484 m/s','1489 m/s');
%%
rfc_p = zeros(1,6480,128);
for c = 1:128
   rfc_p(1,:,c) = circshift(rfc_i(1,:,c),[0 -round(geo(c)-delays(c)) 0]); 
end
%%
rfc_p = zeros(size(rfc_i));
for c = 1:128
   rfc_p(1,:,c) = circshift(rfc_i(1,:,c),[0 round(delays(c)) 0]); 
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



