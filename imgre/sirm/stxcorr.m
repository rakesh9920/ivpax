function [xcgram pos] = stxcorr(vect1, vect2, nkern, noverlap, varargin)
% Short-term cross-correlation

nsamples = size(vect1, 2);

if nargin > 4
    switch varargin{1}
        case 'hanning'
            win = hanning(nkern).';
        otherwise
            win = ones(1,nkern).'; 
    end
end

% inequality: nsteps*nkern - (nsteps-1)*noverlap <= nsamples
nsteps = floor((nsamples - noverlap)/(nkern - noverlap));

xcgram = zeros(1024*2-1, nsteps);
pos = zeros(1, nsteps);
pad = zeros(1, (1024-nkern)/2);

for step = 1:nsteps
    
    front = (step - 1)*(nkern - noverlap) + 1;
    back = front + nkern - 1;
    
    sig1 = [pad vect1(front:back).*win pad];
    sig2 = [pad vect2(front:back).*win pad];
    
    xcgram(:, step) = xcorr(sig1, sig2,'coeff').';
    pos(step) = (front + back)/2;
end

end

