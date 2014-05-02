function [xcgram pos] = stxcorr(vect1, vect2, nkern, noverlap, varargin)
% Short-term cross-correlation

if nargin > 4
    params = varargin{1};
    assert(isa(params, 'containers.Map'));
    
    if isKey(params, 'window')
        window = params('window');
    end
end

nsamples = size(vect1, 2);

if exist('window', 'var')
    switch window
        case 'hanning'   
            win = hanning(nsamples).';
        case 'gaussian'
            win = gausswin(nsamples).';
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

