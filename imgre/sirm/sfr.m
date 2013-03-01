function [fr] = sfr(srcpts, fieldpts, freq, soundspeed, area)

%fmin = frange(1);
%fmax = frange(2);
upicmsg('Running sfr.m ...');
numsrcpts = size(srcpts, 2);
numfieldpts = size(fieldpts, 2);

%freq = fmin:fres:fmax;
omega = 2*pi.*freq;
wavenum = omega./soundspeed;

fr = zeros(length(wavenum), numfieldpts);

upicstatus('Calculating pair-wise distances');
dist = sqrt(sqdistance(srcpts, fieldpts));
upicstatus(1);

bar = upicbar('Calculating frequency response ...');
%prog = progress(0,0,'fsr');
for fld = 1:numfieldpts
    
    upicbar(bar, fld/numfieldpts);
    %progress(fld/numfieldpts,0,'fsr',prog);

    r = dist(:, fld);
    
    greens = ((r.^-1).')*exp(-1i.*r*wavenum);
    pres = (1i/(2*pi)).*area./numsrcpts.*wavenum.*greens;    
    fr(:, fld) = pres;
end

end

