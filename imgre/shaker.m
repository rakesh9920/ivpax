addpath ./sirm/
addpath ./beamformer/


[header, ~] = readDAQ('./10hz/', ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;%header(2);
nSample = header(3);

Rfc = zeros(nChannel, nSample, nFrame, 'int16');

for fr = 1:nFrame
   [~, rf] = readDAQ('./10hz/', ones(1,128), fr, true);
   Rfc(:,:,fr) = rf.';
end

FilteredRfc = bandpass(double(Rfc), 6.6, 0.80, 40);
%%
for i = 1:nFrame
   imagesc(20.*log10(abs(squeeze(FilteredRfc(:,:,i)))).');
   title(num2str(i));
   pause(0.1);
end


%%
for i = 1:nFrame
   plot(FilteredRfc(64,:,i));
   title(num2str(i));
   pause(0.1);
end
%%

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];

nCompare = 200;
delta = 4e-6;
deltaR = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;

FieldPos = [ones(1, nCompare).*0; zeros(1, nCompare); 0.0289 + deltaR];

BfSigMat = gtbeamform(FilteredRfc, [], RxPos, FieldPos, 200, 'plane');

VelEst = ftdoppler2(BfSigMat, FieldPos, 100);

plot(VelEst);
