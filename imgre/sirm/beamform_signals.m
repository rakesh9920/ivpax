%% beamform receive signals

RxSigMat = [shiftdim(Rx1Sig, -1); shiftdim(Rx2Sig, -1);...
    shiftdim(Rx3Sig, -1); shiftdim(Rx4Sig, -1)];

TxPos = [0; 0; 0];

RxPos(:,1) = [0.0012*cos(pi/4); 0.0012*sin(pi/4); 0];
RxPos(:,2) = [0.0012*cos(3*pi/4); 0.0012*sin(3*pi/4); 0];
RxPos(:,3) = [0.0012*cos(5*pi/4); 0.0012*sin(5*pi/4); 0];
RxPos(:,4) = [0.0012*cos(7*pi/4); 0.0012*sin(7*pi/4); 0];

FieldPos = [zeros(1,54); zeros(1,54); 0.025:1.875e-6:0.0251];
%FieldPos = [0; 0; 0.03];
%[xgrid ygrid zgrid] = meshgrid(linspace(-0.01, 0.01, 100), 0, linspace(0,0.0384, 2049));
%fldpts2 = [reshape(xgrid, 1, []); reshape(ygrid, 1, []); reshape(zgrid, 1, [])];
%[bfsig bfmat] = gfbeamform(rxsignals, txpts, rxpts, fldpts);
%bfsig2 = qbeamform(rxsignals, txpts, rxpts, fldpts2);

BfSigMat = gfbeamform2(RxSigMat(:,:,:), TxPos, RxPos, FieldPos, 150);

if (exist('VERBOSE', 'var'))
    figure; plot(bfsig(1,:,1));
end
