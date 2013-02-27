function [fsir] = fsir(srcpts, fieldpts, frange, nfft, soundspeed)

fmin = frange(1);
fmax = frange(2);

numsrcpts = size(srcpts, 2);
numfieldpts = size(fieldpts, 2);

fsir = zeros(nfft, numfieldpts);
wavenum = 2*pi.*linspace(fmin, fmax, nfft)./soundspeed;

dist = sqrt(sqdistance(srcpts, fieldpts));

prog = progress(0, 0, '');
for fld = 1:numfieldpts
    
    progress(fld/numfieldpts, 0, '', prog);
    
    pres = zeros(1, nfft); % normalized wrt characteristic impedance
    
    for src = 1:numsrcpts

        r = dist(src, fld);
        
        for fnum = 1:nfft
            
            k = wavenum(fnum);
            pres(fnum) = pres(fnum) + 1i*k/(2*pi)*exp(-1i*k*r)/r;
        end
    end  
    
    fsir(:, fld) = pres.';
end

end

