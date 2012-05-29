%%
rfc_c = zeromean(rfc_noabb);
rfc_b = bandpass(rfc_c,6.6,5.28,40);
%%
cutoff1 = 500;
cutoff2 = 700;
refchan = 72;

refsig = squeeze(rfc_b(1,cutoff1:cutoff2,refchan))';

xcv = zeros(1,128);
sig = zeros(128,(cutoff2-cutoff1+1)*2-1);

for channel = 1:128
   
    signal = squeeze(rfc_b(1,cutoff1:cutoff2,channel))';
    sig(channel,:) = xcorr(refsig, signal, 'coeff');
    xcv(channel) = max(sig(channel,:));
end

%%
for c = 1:128
    plot(sig(c,:));
    pause;
end
%%
for c = 1:128
    plot(rfc_b(1,500:700,c));
    title(num2str(c));
    pause;
end