function [img] = envelope(bfmat)
% Envelope detection for RF data


[numoflines, samplesperline] = size(bfmat);
img = zeros(numoflines, samplesperline,class(bfmat));

for line = 1:numoflines
       
   img(line,:) = abs(hilbert(double(bfmat(line,:))));
end

end

