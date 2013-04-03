function [vsig ] = ftdoppler(bfm, nkern, ntsample, txdist)
% Doppler flow estimate using full cross-correlation

[nsamples npoints nframes] = size(bfm);

%dmat = zeros(nlines, nsteps, nframes - 1);
%xcmat = zeros(nlines, nsteps, nframes - 1, 1024*2 - 1);
vsig = zeros(1, npoints, nframes);
soundspeed = 1500;
samplefreq = 40e6;

if mod(nkern,2) == 0
    nkern = nkern + 1;
end

if mod(ntsample,2) == 0
    ntsample = ntsample + 1;
end

ntsamplehalf = (ntsample-1)/2;
nkernhalf = (nkern-1)/2;

bar = upicbar('Calculating velocity...');
for frame = 1:(nframes - 1)

    
    for pt = 1430%1:npoints
        
        upicbar(bar, ((frame-1)*npoints+pt)/((nframes-1)*npoints));
        
        txdelay1 = round(txdist(1, pt)/soundspeed*samplefreq);
        
        tfront = txdelay1 - ntsamplehalf;
        if tfront < 1
            tfront = 1;
        end
        tback = txdelay1 + ntsamplehalf;
        if tback > nsamples
            tback = nsamples;
        end
        
        win1 = [zeros(tfront-1, 1); rectwin(tback-tfront+1); zeros(nsamples-tback,1)];
        %vect1 = bfm(tfront:tback, pt, frame);
        vect1 = win1.*bfm(:, pt, frame);
        
        plot(vect1); hold on;
        
        
        dfront = pt - nkernhalf;
        if dfront < 1
            dfront = pt;
        end
        dback = pt + nkernhalf;
        if dback > npoints
            dback = npoints;
        end
        
        xclist = zeros(1, dfront - dback + 1); ind = 1;
        
        dvect = dfront:dback;
        for pt2 = dvect
            
            txdelay2 = round(txdist(1, pt2)/soundspeed*samplefreq);
            
            tfront = txdelay2 - ntsamplehalf;
            if tfront < 1
                tfront = 1;
            end
            tback = txdelay2 + ntsamplehalf;
            if tback > nsamples
                tback = nsamples;
            end
            
            win2 = [zeros(tfront-1, 1); rectwin(tback-tfront+1); zeros(nsamples-tback,1)];
            %vect2 = bfm(tfront:tback, pt2, frame + 1);
            vect2 = win2.*bfm(:, pt2, frame + 1);
            xclist(ind) = max(xcorr(vect1, vect2));
            ind = ind + 1;
            
            plot(vect2, 'r');
        end
        
        [val ind] = max(xclist);
        vsig(1, pt, frame) = (dvect(ind) - pt)*1.875e-5/(1/60);
        
        
    end
end


end