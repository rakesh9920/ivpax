function [RfMatOut] = alignsumrf(varargin)
% Aligns (by zero-padding) and sums RF matrices based on their start times.

nMats = size(varargin, 2);

% set output matrix to the first input rf matrix.
RfMatOut = varargin{1};
sampleFrequency = RfMatOut.meta.sampleFrequency;

for mat = 2:nMats
    
    RfMat = varargin{mat};
    startTime = RfMat.meta.startTime;
    
    % determine front pad and which matrix to pad (if necessary)
    frontPad = round((startTime - RfMatOut.meta.startTime)*sampleFrequency);
    
    if frontPad > 0
        RfMat = padarray(RfMat, [frontPad 0 0], 'pre');
    elseif frontPad < 0
        RfMatOut = padarray(RfMatOut, [-frontPad 0 0], 'pre');
        RfMatOut.meta.startTime = startTime;
    end
    
    % determine back pad and which matrix to pad (if necessary)
    backPad = size(RfMatOut, 1) - size(RfMat, 1);
    
    if backPad > 0
        RfMat = padarray(RfMat, [backPad 0 0], 'post');
    elseif backPad < 0
        RfMatOut = padarray(RfMatOut, [-backPad 0 0], 'post');
    end
    
    RfMatOut = RfMatOut + RfMat;
end


end

