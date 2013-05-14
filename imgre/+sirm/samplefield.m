function [sfield] = samplefield(vfield, speeds, loc, pixelSize)
%

numpts = size(loc, 2);
numframes = size(vfield, 3);
sfield = zeros(3, numpts, numframes);

for fr = 1:numframes
    
    dist(:,:,1) = sqrt(sqdistance(loc(1,:), vfield(1,:,fr)));
    dist(:,:,2) = sqrt(sqdistance(loc(2,:), vfield(2,:,fr)));
    dist(:,:,3) = sqrt(sqdistance(loc(3,:), vfield(3,:,fr)));
    
    for pt = 1:size(loc, 2)
        
        d = shiftdim(dist(pt,:,:), 1);
        
        inpixel = all(d <= repmat(pixelSize./2, size(vfield,2), 1));
        
        mspeed = mean(speeds(:,inpixel.'), 2);
        if isempty(mspeed)
            continue;
        end
        sfield(:, pt, fr) = mspeed;
    end
end

sfield(isnan(sfield)) = 0;

end

