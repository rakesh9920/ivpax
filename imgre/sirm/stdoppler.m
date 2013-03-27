function [dmat pos xcmat] = stdoppler(bfm, nkern, noverlap)
% Doppler flow estimate using short-term cross-correlation (windowed cross-
% correlation).

% Inputs:
%   bfm: RF data organized by [line, sample, frame]
%   nkern: number of samples in correlation window
%   noverlap: number of samples overlapping between windows
%
% Outputs:
%   dmat: delay data (in samples) organized by [line, sample, frame]

[nlines nsamples nframes] = size(bfm);
nsteps = floor((nsamples - noverlap)/(nkern - noverlap));

dmat = zeros(nlines, nsteps, nframes - 1);
xcmat = zeros(nlines, nsteps, nframes - 1, 1024*2 - 1);

for frame = 1:(nframes - 1)
   
    for line = 1:nlines
       
        vect1 = bfm(line, :, frame);
        vect2 = bfm(line, :, frame + 1);
        
        [xcg pos] = stxcorr(vect1, vect2, nkern, noverlap, 'hanning');
        
        xcmat(line, :, frame, :) = reshape(xcg.', 1, nsteps, 1, []);
        
        [val ind] = max(xcg, [], 1);
        
        dmat(line, :, frame) = ind - 2047;
    end
end


end