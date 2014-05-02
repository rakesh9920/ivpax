function [pfield] = pfieldgen(gridsz, soundspeed, spatres, sampfreq, tmax)

numrows = gridsz(1);
numcols = gridsz(2);

latres = spatres(1);
axres = spatres(2);
timeres = 1/sampfreq;

numofsamples = floor(tmax*sampfreq);

tsig = ((1:numofsamples) - 15).*timeres;
sig = gauspuls(tsig, 6.6e6, 0.8);

array = ((1:128) - 1).*312.5e-6 + 156.26e-6;
txdelays = bfdelays(array, [20e-3 20e-3], soundspeed, timeres);

rcoords = ((1:numrows) - 1).*axres + axres/2;
ccords =  ((1:numcols) - 1).*latres + latres/2;

pfield = zeros([gridsz numofsamples]);

prog = progress(0);

for row = 1:numrows
    
    progress(row/numrows, 0, 'pfield', prog);
    
    for col = 1:numcols
        
        pres = zeros(1, numofsamples);
        
        for src = 1:length(array)
            
            dist = sqrt((rcoords(row) - array(src))^2 + ccords(col)^2);
            
            delay = txdelays(src) + round(dist/soundspeed/timeres);
            
            pres = pres + shift(sig, delay);
        end
        
        pfield(row, col, :) = pres;
    end
end

end

function svect = shift(vect, n)

N = length(vect);

if abs(n) >= N
    svect = zeros(1, N);
elseif n > 0
    svect = [zeros(1, n) vect(1:(N - n))];
else
    svect = [vect((-n + 1):end) zeros(1, -n)];
end
end

function delays = bfdelays(array, focus, c, tres)

focx = focus(1);
focy = focus(2);
delays = zeros(1, length(array));

for e = 1:length(array)
    delays(e) = round(sqrt((array(e) - focx)^2 + focy^2)/c/tres);
end

delays = -(delays - min(delays));
end
