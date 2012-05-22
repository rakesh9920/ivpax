cutoff1 = 900;
cutoff2 = 1300;
refchan = 70;

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