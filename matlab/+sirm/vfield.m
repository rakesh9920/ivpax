function [fldpts] = vfield(icoords, speeds, prf, duration)

numpts = size(icoords, 2);
nframes = round(prf*duration);
increment = speeds./prf;

fldpts = repmat(icoords, [1 1 nframes]);

for frame = 2:nframes
   
    fldpts(:, :, frame) = fldpts(:, :, frame) + increment.*(frame - 1);
end

end

