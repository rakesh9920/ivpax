function [xcgram] = stxcorr(vect1, vect2, nkern, noverlap)

nsamples = size(vect1, 2);

% inequality: nsteps*nkern - (nsteps-1)*noverlap <= nsamples
nsteps = floor((nsamples - noverlap)/(nkern - noverlap));

xcgram = zeros(2*nkern-1, nsteps);

for step = 1:nsteps
   
    front = (step - 1)*(nkern - noverlap) + 1;
    back = front + nkern - 1;
    
    xcgram(:, step) = xcorr(vect1(front:back), vect2(front:back),'coeff').';
end

end

