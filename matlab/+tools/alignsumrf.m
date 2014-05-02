function [RfMatOut] = alignsumrf(varargin)
%ALIGNSUMRF Aligns (by zero-padding) and sums RF matrices based on their
%start times and frames.

nMats = size(varargin, 2);

% set output matrix to the first input rf matrix.
RfMatOut = varargin{1};
sampleFrequency = RfMatOut.meta.SampleFrequency;

for mat = 2:nMats
    
    RfMat = varargin{mat};
    startTime = RfMat.meta.StartTime;
    startFrame = RfMat.meta.StartFrame;
    endFrame = RfMat.meta.EndFrame;
    
    % determine frame padding and which matrix to pad (if necessary)
    frontFramePad =  startFrame - RfMatOut.meta.StartFrame;
    
    if frontFramePad > 0
        RfMat = padarray(RfMat, [0 0 frontFramePad], 'pre');
    elseif frontFramePad < 0
        RfMatOut = padarray(RfMatOut, [0 0 -frontFramePad], 'pre');
        RfMatOut.meta.StartFrame = startFrame;
    end
    
    backFramePad = RfMatOut.meta.EndFrame - endFrame;
    
    if backFramePad > 0
        RfMat = padarray(RfMat, [0 0 backFramePad], 'post');
    elseif backFramePad < 0
        RfMatOut = padarray(RfMatOut, [0 0 -backFramePad], 'post');
        RfMatOut.meta.EndFrame = endFrame;
    end
    
    % determine sample padding and which matrix to pad (if necessary)
    frontPad = round((startTime - RfMatOut.meta.StartTime)*sampleFrequency);
    
    if frontPad > 0
        RfMat = padarray(RfMat, [frontPad 0 0], 'pre');
    elseif frontPad < 0
        RfMatOut = padarray(RfMatOut, [-frontPad 0 0], 'pre');
        RfMatOut.meta.StartTime = startTime;
    end
    
    backPad = size(RfMatOut, 1) - size(RfMat, 1);
    
    if backPad > 0
        RfMat = padarray(RfMat, [backPad 0 0], 'post');
    elseif backPad < 0
        RfMatOut = padarray(RfMatOut, [-backPad 0 0], 'post');
    end
    
    % add padded rf data to cumulative sum
    RfMatOut = RfMatOut + RfMat;
end


end

