function [list coords] = scattergen(density, gridsz, amprange, phaserange)

% density, grid size, amplitude range, phase range

numrows = gridsz(1);
numcols = gridsz(2);
numlayers = gridsz(3);

numofcells = numrows*numcols*numlayers;
numofpoints = round(density*numofcells);

phmin = phaserange(1);
phmax = phaserange(2);
phrange = phmax - phmin;
ampmin = amprange(1);
ampmax = amprange(2);
amprange = ampmax - ampmin;

%grid = zeros(numrows, numcols, numlayers);
list = zeros(1, numofpoints);
coords = zeros(3, numofpoints);

for p = 1:numofpoints
    
    phase = rand*phrange + phmin;
    amp = rand*amprange + ampmin;
    ramp = amp*cos(phase);
    iamp = amp*sin(phase);
    
    while true
        x = 1 + round(rand*(numrows - 1));
        y = 1 + round(rand*(numcols - 1));
        z = 1 + round(rand*(numlayers - 1));
        
        if ~all([any(coords(1,:) == x) any(coords(2,:) == y) any(coords(3,:) == z)])
           
            %grid(x,y,z) = ramp + 1i*iamp;
            list(p) = ramp + 1i*iamp;
            coords(1,p) = x;
            coords(2,p) = y;
            coords(3,p) = z;
            break;
        end
    end
end


end

