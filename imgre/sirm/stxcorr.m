function [xcgram pos] = stxcorr(vect1, vect2, nkern, noverlap)
% Short-term cross-correlation

nsamples = size(vect1, 2);

% inequality: nsteps*nkern - (nsteps-1)*noverlap <= nsamples
nsteps = floor((nsamples - noverlap)/(nkern - noverlap));

xcgram = zeros(2*nkern-1, nsteps);
pos = zeros(1, nsteps);
for step = 1:nsteps
   
    front = (step - 1)*(nkern - noverlap) + 1;
    back = front + nkern - 1;
    
    xcgram(:, step) = xcorr(vect1(front:back), vect2(front:back),'coeff').';
    pos(step) = (front + back)/2;
end

end

