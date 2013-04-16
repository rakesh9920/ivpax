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
    figure; plot(BfSigMat(:,1,1));
end

%%

del = FieldPos(:,1) - RxPos(:,1);
r = sqrt(sum(del.^2));
theta = acos(del(3)/r);
phi = atan(del(2)/del(1));

R = -0.01:1.875e-6:0.001;
x = R.*sin(theta).*cos(phi);
y = R.*sin(theta).*sin(phi);
z = R.*cos(theta);

pts = bsxfun(@plus, FieldPos(:,1), [x; y; z]);

figure;
plot3(Tx1Mesh(1,:), Tx1Mesh(2,:), Tx1Mesh(3,:),'b.'); hold on;
plot3(Rx1Mesh(1,:),Rx1Mesh(2,:),Rx1Mesh(3,:),'r.');
plot3(Rx2Mesh(1,:),Rx2Mesh(2,:),Rx2Mesh(3,:),'g.');
plot3(Rx3Mesh(1,:),Rx3Mesh(2,:),Rx3Mesh(3,:),'c.');
plot3(Rx4Mesh(1,:),Rx4Mesh(2,:),Rx4Mesh(3,:),'k.');
plot3(FieldPos(1,1),FieldPos(2,1),FieldPos(3,1),'ro');
plot3(RxPos(1,1),RxPos(2,1),RxPos(3,1),'go');
plot3(pts(1,:),pts(2,:),pts(3,:),'o');