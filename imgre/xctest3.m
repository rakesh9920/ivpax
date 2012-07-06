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

% REMOVE NOISE NEAR TRANSDUCER
endsample = 2500;
rfc_i(1,1:endsample,:) = 0;
%%
centerchannel = 56;
pitch = 300e-6;
numofchannels = 128;
wavespeed = 1420;
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;
bfline = zeros(1,ceil(numofsamples/2));

x = array(centerchannel);
delays = zeros(ceil(numofsamples/2),numofchannels);
activeChannels = 1:128;

for sample = 1:ceil(numofsamples/2)
    
    y = sample/(40e6*upfactor)*wavespeed;
    
    for channel = 1:numofchannels
        delay = round((sqrt((array(channel) - x)^2 + y^2) + y)/wavespeed*(40e6*upfactor));
        delays(sample, channel) = delay;
        if delay <= numofsamples && delay > 0
            bfline(sample) = bfline(sample) + rfc_i(1, int16(delay), channel);
        end
    end
end
%%
intstart = 4100;
intend = 4600;
threshold = 1000;
slope = diff(bfline);
roots = findzeros(slope,1);
roots((roots < intstart) | (roots > intend)) = [];
roots(bfline(roots) < threshold) = [];
s0 = roots(1);
geom_delays = delays(s0,:) - min(delays(s0,:));
%% CORRECT FOR GEOM DELAYS
rfc_p = zeros(size(rfc_i));
for channel = 1:128
    rfc_p(1,:,channel) = circshift(rfc_i(1,:,channel),[0 -round(geom_delays(channel)) 0]);
end
%%
intstart = 8200;
intend = 9200;
wave = zeros(numofchannels, 3);
for channel = 1:numofchannels
    sig = rfc_p(1,:,channel);
    slope = diff(sig(intstart:intend));
    threshold = 0.40*max(sig(intstart:intend));
    roots = findzeros(slope,1) + intstart;
    roots(sig(roots) < threshold) = [];
    wave(channel,1:length(roots)) = roots(1:length(roots));
end
%%
front = zeros(1,numofchannels);
front(centerchannel) = s0*2;%wave(centerchannel, 3);
for channel = (centerchannel+1):numofchannels
    [val ind] = min(abs(wave(channel,:) - front(channel-1)));
    front(channel) = wave(channel,ind);
end
for channel = (centerchannel):-1:1
    [val ind] = min(abs(wave(channel,:) - front(channel+1)));
    front(channel) = wave(channel,ind);
end


