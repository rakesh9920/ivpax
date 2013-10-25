import beamform.*
import ultrasonix.*
import tools.*

%%
global SOUND_SPEED SAMPLE_FREQUENCY
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1450;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

prms = containers.Map();
prms('progress') = true;
prms('planetx') = true;
prms('filter') = true;
prms('channels') = 0:15;
prms('fc') = 6e6;
prms('bw') = 6e6;

pitch = 245e-6;
nElement = 16;

RxPos = [(1:nElement).*pitch - nElement/2*pitch - pitch/2; zeros(1, nElement); ...
    zeros(1, nElement)];

TxPos = [];

[X, Y, Z] = ndgrid(-0.005:0.0001:0.005, 0, 0:0.0001:0.01);
FieldPos = [X(:) Y(:) Z(:)].';

%%
daq2mat([], [], prms);
%%

BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, 100, prms);
BfMat = reshape(BfMat, [101 101 101]);

DMat = zeros(size(BfMat));
for i = 1:101
    for j = 1:101
        DMat(:,i,j) = abs(hilbert(BfMat(:,i,j)));
    end
end

ImgMat = squeeze(DMat(51,:,:));

imtool(20.*log10(ImgMat./max(max(ImgMat))), [-20 0]);
