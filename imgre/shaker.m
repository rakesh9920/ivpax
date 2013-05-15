import beamform.*
import sirm.*
import ultrasonix.*
import flow.*
%% read in RAW daq data
[header, ~] = readDAQ('./rfdata/dataset2/tx10hz/', ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;%header(2);
nSample = header(3);

Rfc = zeros(nChannel, nSample, nFrame, 'int16');

for fr = 1:nFrame
   [~, rf] = readDAQ('./rfdata/dataset2/tx10hz/', ones(1,128), fr, true);
   Rfc(:,:,fr) = rf.';
end

FilteredRfc = bandpass(double(Rfc), 6.6, 0.80, 40);
%%
for i = 1:nFrame
   imagesc(20.*log10(abs(squeeze(FilteredRfc(:,:,i)))./600).');
   title(num2str(i));
   pause(0.1);
end
%%
for i = 1:nFrame
   plot(FilteredRfc(64,:,i));
   title(num2str(i));
   axis([250 1200 -100 100]);
   pause(0.1);
end
%%
for i = 1:(nFrame/10)
   imagesc(20.*log10(abs(squeeze(RfcAvg(:,:,i)))).');
   title(num2str(i));
   pause(0.1);
end
%%
RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
nCompare = 200;
delta = 0.1e-6;
FieldPos = [0; 0; 0.020];

VelEst = axialest(FilteredRfc, [], RxPos, FieldPos, nCompare, delta, ...
    'progress', true);

plot(VelEst,':.');
%%
RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];

nCompare = 400;
delta = 0.1e-6;
deltaR = -(nCompare - 1)/2*delta:delta:(nCompare - 1)/2*delta;

FieldPos = [ones(1, nCompare).*0; zeros(1, nCompare); 0.020 + deltaR];

BfSigMat = gtbeamform(FilteredRfc, [], RxPos, FieldPos, 200, 'plane', true, ...
    'progress', true);

VelEst = ftdoppler2(BfSigMat, FieldPos, 100, 'progress', true);

plot(VelEst,':.');
%% read in AVG daq data
[header, ~] = readDAQ('./rfdata/control/', ones(1,128), 1, true);

nChannel = header(1) + 1;
nFrame = 100;%header(2);
nSample = header(3);

Rfc = zeros(nChannel, nSample, nFrame, 'int16');

for fr = 1:nFrame
   [~, rf] = readDAQ('./rfdata/control/', ones(1,128), fr, true);
   Rfc(:,:,fr) = rf.';
end
%%
RfcAvg = zeros(nChannel, nSample, nFrame/10);
for i = 1:(nFrame/10)
   
    RfcAvg(:,:,i) = mean(FilteredRfc(:,:,i:(i+9)),3);
end
%%
for i = 1:(nFrame/10)
   plot(RfcAvg(64,:,i));
   title(num2str(i));
   pause(0.1);
end


