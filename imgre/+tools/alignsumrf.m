function [RfMatOut] = alignsumrf(varargin)
% Aligns (by zero-padding) and sums RF matrices based on their start times.

nMats = size(varargin, 2);

% set output matrix to the first input rf matrix.
RfMatOut = varargin{1};
sampleFrequency = RfMatOut.meta.sampleFrequency;

for mat = 2:nMats
    
    RfMat = varargin{mat};
    startTime = RfMat.meta.startTime;
    startFrame = RfMat.meta.startFrame;
    endFrame = RfMat.meta.endFrame;
    
    % determine frame padding and which matrix to pad (if necessary)
    frontFramePad =  startFrame - RfMatOut.meta.startFrame;
    
    if frontFramePad > 0
        RfMat = padarray(RfMat, [0 0 frontFramePad], 'pre');
    elseif frontFramePad < 0
        RfMatOut = padarray(RfMatOut, [0 0 -frontFramePad], 'pre');
        RfMatOut.meta.startFrame = startFrame;
    end
    
    backFramePad = RfMatOut.meta.endFrame - endFrame;
    
    if backFramePad > 0
        RfMat = padarray(RfMat, [0 0 backFramePad], 'pre');
    elseif backFramePad < 0
        RfMatOut = padarray(RfMatOut, [0 0 -backFramePad], 'pre');
        RfMatOut.meta.endFrame = endFrame;
    end
    
    % determine sample padding and which matrix to pad (if necessary)
    frontPad = round((startTime - RfMatOut.meta.startTime)*sampleFrequency);
    
    if frontPad > 0
        RfMat = padarray(RfMat, [frontPad 0 0], 'pre');
    elseif frontPad < 0
        RfMatOut = padarray(RfMatOut, [-frontPad 0 0], 'pre');
        RfMatOut.meta.startTime = startTime;
    end
    
    backPad = size(RfMatOut, 1) - size(RfMat, 1);
    
    if backPad > 0
        RfMat = padarray(RfMat, [backPad 0 0], 'post');
    elseif backPad < 0
        RfMatOut = padarray(RfMatOut, [-backPad 0 0], 'post');
    end
    
    RfMatOut = RfMatOut + RfMat;
end


end

