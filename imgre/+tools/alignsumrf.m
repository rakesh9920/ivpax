function [RfMatOut] = alignsumrf(varargin)
%

import tools.advdouble

nMats = size(varargin, 2);

RfMatOut = varargin{1};

for mat = 2:nMats
    
    RfMat = varargin{mat};
    startTime = RfMat.meta.startTime;
    sampleFreq = RfMat.meta.sampleFreq;
    
    frontPad = round((startTime - RfMatOut.meta.startTime)*sampleFreq);
    
    if frontPad > 0
        RfMat = padarray(RfMat, [frontPad 0 0], 'pre');
    elseif frontPad < 0
        RfMatOut = padarray(RfMatOut, [-frontPad 0 0], 'post');
        RfMatOut.meta.startTime = startTime;
    end
    
    %     backPad = size(RfMatOut, 1) - size(RfMat, 1);
    backPad = length(RfMatOut) - length(RfMat);
    
    if backPad > 0
        RfMat = padarray(RfMat, [backPad 0 0], 'post');
    elseif backPad < 0
        RfMatOut = padarray(RfMatOut, [-backPad 0 0], 'post');
    end
    
    RfMatOut = RfMatOut + RfMat;
end


end

