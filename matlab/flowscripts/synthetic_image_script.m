import beamform.*
import ultrasonix.*
import tools.*

%%
global SOUND_SPEED SAMPLE_FREQUENCY
SOUND_SPEED = 1450;
SAMPLE_FREQUENCY = 40e6;


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

[X, Y, Z] = ndgrid(-0.005:0.000025:0.005, 0, 0:0.000025:0.04);
FieldPos = [X(:) Y(:) Z(:)].';

%%
daq2mat([], [], prms);
%%

BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, 201, prms);
BfMat = reshape(BfMat, [201 401 1601]);

DMat = zeros(size(BfMat));
for i = 1:401
    for j = 1:1601
        DMat(:,i,j) = abs(hilbert(BfMat(:,i,j)));
    end
end

ImgMat = squeeze(DMat(101,:,:));

imtool(20.*log10(ImgMat./max(max(ImgMat))), 'DisplayRange', [-20 0]);
