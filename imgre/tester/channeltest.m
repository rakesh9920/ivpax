%% Angle test
sp = 1;

for ang = 21:20:181
    for channel = 64
        
        subplot(9,1,sp);
        plot(rfc(ang,:,channel));
        sp = sp + 1;
    end
end

clear sp ang
%%

x = 0:1e-3:9999e-3;

[ax h1 h2] = plotyy(x,ch1_avg512_timing, x,ch4_avg512_timing);
h3 = line(x,ch3_avg512_timing,'Parent',ax(2));
set(h3,'Color',[1 0 0]);
set(get(ax(1),'YLabel'),'String','Voltage [V]');
set(get(ax(2),'YLabel'),'String','Voltage [V]');
xlabel('Time [us]');
set(ax(2),'YMinorTick','on');
set(ax(1),'YMinorTick','on');

legend('Receive RF','Receive Input Trigger','Laser Diode Output')
title('Receive, input trigger, and diode waveforms showing relative timing');

figure; plot(x,ch1_raw);
xlabel('Time [us]');
ylabel('Voltage [V]');
title('Receive waveform: [no averaging | 50 dB Gain]');

figure; plot(x,ch1_avg512);
xlabel('Time [us]');
ylabel('Voltage [V]');
title('Receive waveform: 512 averaging, 50 dB Gain');

rf_b = bandpass(transpose(ch1_avg512),7.5,6,1000);

figure; plot(x,rf_b);
xlabel('Time [us]');
ylabel('Voltage [V]');
title('Receive waveform: [bandpass filtered, 512 averaging, 50 dB Gain]');

figure; plot(x,20*log10(envelope(rf_b/0.0339)));
xlabel('Time [us]');
ylabel('Voltage [dB]');
title('Receive waveform envelope: [bandpass filtered, 512 averaging, 50 dB Gain, ref voltage 0.0339 V]');
%% Imaging with Unirad 546 and GPIB

rfc = zeros(1,10000,32,'double');

for channel = 1:32
   
    [t, d] = scopesave(1);
    rfc(1,:,channel) = d;
    pause 
end


%% Channel test

%sum2 = zeros(1,1080,'int16');
%rfc_new = zeros(1,1080,128,'int16');
figure;

for line = 1;
    for channel = 1:128
        
        %subplot(8,1,sp);
        plot(rfc(line,:,channel));
        %plot(sigs(channel,:),'b'); %hold on;
        axis([0 size(rfc,2) -4e4 4e4]);
        title(num2str(channel));
        %sum2 = sum2 + int16(avg_fc2(line,:,channel));
        pause;
    end
end

clear sp ang channel line

%% Cross-correlation

%numofchannels = 128;
%pitch = 300e-6;
%wavespeed = 1482;
%samplingfreq = 40e6;
%timeres = 1/samplingfreq;
%array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;
%refsample = 850;
%refdist = refsample*timeres*wavespeed;
%refpt = [array(39) refdist];
%refsig = double(rfc(line,refsample-winwidth/2:refsample+winwidth/2,refchannel));

winwidth = 300;
line = 77;

refchannel = 39;


[mx ind] = max(rfc(line,:,refchannel));
start = ind - winwidth/2;
stop = ind + winwidth/2;
refsig = double(rfc(line,start:stop,refchannel));

xcv = zeros(1,128);
sigs = zeros(128, winwidth+1);
inds = zeros(1,128);

inds(1) = ind;

for channel = 1:128
   
    %{
    dist = sqrt(sum(([array(channel) 0] - refpt).^2));
    delay = int16((dist - refdist)/wavespeed/timeres);
    start = refsample+delay-winwidth/2;
    stop = refsample+delay+winwidth/2;
    rfsig = double(rfc(line,start:stop,channel));
    %}
    
    [mx ind] = max(rfc(line,:,channel));
    start = ind - winwidth/2;
    stop = ind + winwidth/2;
    
    if start < 0 || stop > 2160
       xcv(channel) = 0; 
       continue;
    end
    
    inds(channel) = ind;
    rfsig = double(rfc(line,start:stop,channel));  
    sigs(channel,:) = rfsig;
    xcv(channel) = max(xcorr(rfsig,refsig,'coeff'));
end

clear mn pitch line numofchannels refchannel refsample samplingfreq start 
clear stop timeres array ind wavespeed winwidth rfsig refsig mx channel 
%xcv = xcv./xcv(ref);