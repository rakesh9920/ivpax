%% FIND MAX FRAME
cutoff1 = 500;

e = abs(rfc(:,cutoff1:end,:));

[v indc] = max(max(max(e)));
[v indy] = max(max(e(:,:,indc)));
[v indx] = max(e(:,indy,indc));

indy = indy + cutoff1 - 1;
indx
indy
indc
%% UPSAMPLE
rfc_c = zeromean(rfc(indx,:,:));
upfactor = 8;
rfc_i = zeros(1,size(rfc_c,2)*upfactor,size(rfc_c,3));
for channel = 1:128
    rfc_i(1,:,channel) = interp(rfc_c(1,:,channel),upfactor);
end
rfc_i = bandpass(rfc_i,5,4.5,40*upfactor);
[numoflines numofsamples numofchannels] = size(rfc_i);
rfc_i = reshape(rfc_i,numoflines, numofsamples, numofchannels);

% REMOVE NOISE NEAR TRANSDUCER
endsample = 1000;
rfc_i(1,1:endsample,:) = 0;
%%
centerchannel = 68; % !!!!!!!!!! 54
pitch = 300e-6;
numofchannels = 128;
speeds = 1482; % !!!!!!!!!! 
lse = zeros(size(speeds));
for i = 1:length(speeds)
    wavespeed = speeds(i);
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
    %% FIND LOCATION
    intstart = 3000; % !!!!!!!!!! 1000
    intend = 6000; % !!!!!!!!!! 4000
    threshold = 12000; % !!!!!!!!!! 40000
    slope = diff(bfline);
    roots = findzeros(slope,1);
    roots((roots < intstart) | (roots > intend)) = [];
    roots(bfline(roots) < threshold) = [];
    %s0 = roots(1) ;
    s0 = wirepos;
    geom_delays = delays(s0,:) - min(delays(s0,:));
    %% CORRECT FOR GEOM DELAYS
    rfc_p = zeros(size(rfc_i));
    for channel = 1:128
        rfc_p(1,:,channel) = circshift(rfc_i(1,:,channel),[0 -round(geom_delays(channel)) 0]);
    end
    %% FIND CANDIDATE MAXIMUMS
    intstart = 4000; % !!!!!!!!!! 2000
    intend = 12000; % !!!!!!!!!! 8000
    wave = zeros(numofchannels, 5);
    for channel = 1:numofchannels
        sig = rfc_p(1,:,channel);
        slope = diff(sig(intstart:intend));
        threshold = 0.15*max(sig(intstart:intend)); % !!!!!!!!!!
        roots = findzeros(slope,1) + intstart;
        roots(sig(roots) < threshold) = [];
        wave(channel,1:length(roots)) = roots(1:length(roots));
    end
    %% SEED AND FIND WAVEFRONT
    front = zeros(1,numofchannels);
    front(centerchannel) = 7320; % !!!!!!!!!! 5452
    for channel = (centerchannel+1):numofchannels
        [val ind] = min(abs(wave(channel,:) - front(channel-1)));
        front(channel) = wave(channel,ind);
    end
    for channel = (centerchannel):-1:1
        [val ind] = min(abs(wave(channel,:) - front(channel+1)));
        front(channel) = wave(channel,ind);
    end
    %% CALCULATE LEASTE SQUARES PHASE ERROR
    index = 1:128;
    index(index == 90 | index == 26) = [];
    lse(i) = sum((front(index) - mean(front(index))).^2);
end

%{
figure; imagesc(squeeze(rfc_p));
hold on;
plot(wave,'.');
plot(front,'o');
%}


%% 

index = 1:128; index(90) = []; index(26) = [];
figure;
%{
plot(-(nfront1 - min(nfront1(index))).*3.125,'.');
hold on;
plot(-(nfront2 - min(nfront2(index))).*3.125,'r.');
plot(-(nfront3 - min(nfront3(index))).*3.125,'g.');
plot(-(nfront4 - min(nfront4(index))).*3.125,'k.');
%}
plot(-(nfront1 - min(nfront1(10))).*3.125,'.');
hold on;
plot(-(nfront2 - min(nfront2(36))).*3.125,'r.');
plot(-(nfront3 - min(nfront3(56))).*3.125,'g.');
plot(-(nfront4 - min(nfront4(86))).*3.125,'k.');
plot(36:128,-(nfront5(36:end) - min(nfront5(118))).*3.125,'c.');
legend('pos 1 (10)','pos 2 (36)','pos 3 (56)','pos 4 (86)','pos 5 (118)');
xlabel('channel');
ylabel('time [ns]');
title('phase error as a function of position (using wave speed = 1483 m/s)');

%%
figure;
plot(-(front1 - front1(69)).*3.125,'.');
hold on;
plot(-(front2 - front2(69)).*3.125,'r.');
plot(-(front3 - front3(69)).*3.125,'g.');
legend('plane 64 tx','plane 128 tx', 'focused 64 tx');
xlabel('channel');
ylabel('time [ns]');
title('phase error for different transmit types (using wave speed = 1521 m/s');

%%
figure;
plot(-(front1451 - front1451(54)).*3.125,'.'); hold on;
plot(-(front1461 - front1461(54)).*3.125,'r.');
plot(-(front1471 - front1471(54)).*3.125,'g.');
plot(-(front1481 - front1481(54)).*3.125,'c.');
plot(-(front1491 - front1491(54)).*3.125,'k.');
plot(-(front1501 - front1501(54)).*3.125,'y.');
plot(-(front1511 - front1511(54)).*3.125,'m.');

legend('1451 m/s','1461 m/s','1471 m/s','1481 m/s','1491 m/s','1501 m/s','1511 m/s');
xlabel('channel');
ylabel('time [ns]');





