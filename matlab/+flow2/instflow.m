function [VelMat] = instflow(BfMat, varargin)
%INSTFLOW

import tools.dirprompt tools.varorfile tools.loadadv tools.advdouble tools.saveadv
import flow2.instdoppler

Argsin = inputParser;
Argsin.KeepUnmatched = true;
addOptional(Argsin, 'window', 'rectwin');
addOptional(Argsin, 'averaging', 1);
addOptional(Argsin, 'resample', 1);
addOptional(Argsin, 'SOUND_SPEED', 1500);
addOptional(Argsin, 'SAMPLE_FREQUENCY', 40e6);
addOptional(Argsin, 'CENTER_FREQUENCY', 5e6);
parse(Argsin, varargin{:});

window = Argsin.Results.window;
averaging = Argsin.Results.averaging;
resample = Argsin.Results.resample;

BfMat = double(BfMat);

[nSample, nFrame, nPos] = size(BfMat);

if resample > 1
    
    BfMat = reshape(resample(BfMat, resample, 1), [], nFrame, nPos);
    nSample = size(BfMat, 1);
end

switch window
    case 'hanning'
        
        win = hanning(nSample);
        BfMat = bsxfun(@times, BfMat, win);
    case 'gausswin'
        
        win = gausswin(nSample);
        BfMat = bsxfun(@times, BfMat, win);
    case 'rectwin'
        win = rectwin(nSample);
end

if averaging > 1
    
    BfMatAvg = zeros(nSample, nFrame - averaging + 1, nPos);
    
    for frame = 1:(nFrame - averaging + 1)
        BfMatAvg(:,frame,:) = sum(BfMat(:,frame:(frame+averaging-1),:), 2);
    end
end

VelMat = instdoppler(BfMat, Argsin.Unmatched, Argsin.Results);

%     BfMatInterp = zeros(nSample*resample, nPos, nFrame);
%     
%     for pos = 1:nPos
%         
%         for frame = 1:nFrame
%             BfMatInterp(:,frame,pos) = interp(BfMat(:,frame,pos), resample);
%         end
%     end
%     
%     BfMat = BfMatInterp;
%     nSample = nSample*resample;



