function [grid] = scattergen(density, gridsz, amprange, phaserange)

% density, grid size, amplitude range, phase range

numrows = gridsz(1);
numcols = gridsz(2);

numofcells = numrows*numcols;
numofpoints = round(density*numofcells);

phmin = phaserange(1);
phmax = phaserange(2);
phrange = phmax - phmin;
ampmin = amprange(1);
ampmax = amprange(2);
amprange = ampmax - ampmin;

rgrid = zeros(numrows, numcols);
igrid = zeros(numrows, numcols);

for p = 1:numofpoints
    
    phase = rand*phrange + phmin;
    amp = rand*amprange + ampmin;
    ramp = amp*cos(phase);
    iamp = amp*sin(phase);
    
    while true
        x = 1 + round(rand*(numrows - 1));
        y = 1 + round(rand*(numcols - 1));
        
        if rgrid(x, y) == 0
           
            rgrid(x, y) = ramp;
            igrid(x, y) = iamp;
            break;
        end
    end
end

grid = rgrid + 1i.*igrid;

end

