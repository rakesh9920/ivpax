%% short-time cross correlation velocity estimates

[dmat pos] = stdoppler(bfsig, 40, 20);
vmat = 1.875e-5*60.*diff(dmat,1,3);
loc = [zeros(2, length(pos)); (pos - 1).*1.875e-5];
%sf = samplefield(vf, speeds, loc, [0.001 0.001 3.75e-4]);
figure; imagesc(squeeze(vmat),[-0.02 0.02]);
%figure; imagesc(squeeze(sf(3,:,:)), [-0.02 0.02]);
%err = abs(vmat - sf(3,:,3:end));
%figure; imagesc(squeeze(err));
clear dmat pos;

%% instantaneous doppler velocity estimates

vsig = SOUND_SPEED/2/(2*pi*1e6).*instdoppler(bfsig);
plot(vsig);
%% full-time cross correlation velocity estimates

TxDist = sqrt(sqdistance(txpts, fldpts));
FtVel = ftdoppler(bfmat, TxDist, 20, 200);



