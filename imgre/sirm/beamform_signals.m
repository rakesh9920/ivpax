%% beamform receive signals

rxsignals = [shiftdim(rx1sig, -1); shiftdim(rx2sig, -1);...
    shiftdim(rx3sig, -1); shiftdim(rx4sig, -1)];

txpts = [0; 0; 0];

rxpts(:,1) = [0.0012*cos(pi/4); 0.0012*sin(pi/4); 0];
rxpts(:,2) = [0.0012*cos(3*pi/4); 0.0012*sin(3*pi/4); 0];
rxpts(:,3) = [0.0012*cos(5*pi/4); 0.0012*sin(5*pi/4); 0];
rxpts(:,4) = [0.0012*cos(7*pi/4); 0.0012*sin(7*pi/4); 0];

fldpts = [zeros(1,2049); zeros(1,2049); 0:1.875e-5:0.0384];
[xgrid ygrid zgrid] = meshgrid(linspace(-0.01, 0.01, 100), 0, linspace(0,0.0384, 2049));
%fldpts2 = [reshape(xgrid, 1, []); reshape(ygrid, 1, []); reshape(zgrid, 1, [])];
[bfsig bfmat] = gfbeamform(rxsignals, txpts, rxpts, fldpts);
%bfsig2 = qbeamform(rxsignals, txpts, rxpts, fldpts2);

if (exist('VERBOSE', 'var'))
    figure; plot(bfsig(1,:,1));
end

clear rxsignals rxpts;