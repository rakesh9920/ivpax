function [vsig ] = ftdoppler(bfm, nkern, tdelta)
% Doppler flow estimate using full cross-correlation


[nsamples npoints nframes] = size(bfm);

%dmat = zeros(nlines, nsteps, nframes - 1);
%xcmat = zeros(nlines, nsteps, nframes - 1, 1024*2 - 1);
vsig = zeros(1, npoints, nframes);

if mod(nkern,2) == 0
    nkern = nkern + 1;
end

nkernhalf = (nkern-1)/2;

for frame = 1:(nframes - 1)
   
    for pt = 1:npoints
       
        vect1 = bfm(:, pt, frame);
        
        front = pt - nkernhalf;
        if front < 1
            front = pt;
        end
        back = pt + nkernhalf;
        if back > npoints
            back = npoints;
        end
        
        xclist = zeros(1, front - back + 1); ind = 1;
        for pt2 = front:back
            vect2 = bfm(:, pt2, frame + 1);
            xclist(ind) = max(xcorr(vect1, vect2, 'coeff'));
            ind = ind + 1;
        end
        
        
    end
end


end