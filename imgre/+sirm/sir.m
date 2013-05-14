function [ir] = sir(srcpts, fieldpts, tlength, tfreq, soundspeed)

numsrcpts = size(srcpts, 2);
numfieldpts = size(fieldpts, 2);
numtsamples = 2^nextpow2(tlength.*tfreq);

impulsefcn = zeros(1,numtsamples + 1);
impulsefcn(2) = 1;

sr = zeros(numtsamples + 1, numfieldpts);
dist = sqrt(sqdistance(srcpts, fieldpts));

prog = progress(0, 0, '');
for fld = 1:numfieldpts
    
    progress(fld/numfieldpts, 0, '', prog);
    
    pres = zeros(1, numtsamples + 1); % normalized wrt characteristic impedance
    
    for src = 1:numsrcpts

        r = dist(src, fld);
        
        pres = pres + shift(impulsefcn, round(r/soundspeed*tfreq))./(2*pi*r);
    end  
    
    sr(:, fld) = pres.';
end

ir = diff(sr, 1);

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