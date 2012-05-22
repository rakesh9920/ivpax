function [xcv sigs inds] = xcorrelation(rfc, prm)

winwidth = prm.window_width;
line = prm.line;
refchannel = prm.reference_channel;

if prm.photoacoustic == true
    line = 1;
end
if isfield(prm,'sample_cutoff1')
    cutoff1 = prm.sample_cutoff1;
    cutoff2 = prm.sample_cutoff2;
    rfc(line,1:cutoff1,:) = 0;
    rfc(line,cutoff2:end,:) = 0;
end

xcv = zeros(1,128);
sigs = zeros(128, winwidth+1);
inds = zeros(1,128);

[mx ind] = max(rfc(line,:,refchannel));
start = ind - winwidth/2;
stop = ind + winwidth/2;
refsig = double(rfc(line,start:stop,refchannel));
inds(1) = ind;

numofsamples = size(rfc(line,:,refchannel),2);

for channel = 1:128
   
    [mx ind] = max(rfc(line,:,channel));
    start = ind - winwidth/2;
    stop = ind + winwidth/2;
    
    if start < 0 || stop > numofsamples
       xcv(channel) = 0; 
       continue;
    end
    
    inds(channel) = ind;
    rfsig = double(rfc(line,start:stop,channel));  
    sigs(channel,:) = rfsig;
    xcv(channel) = max(xcorr(rfsig,refsig,'coeff'));
end

end

