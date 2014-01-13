function [VelMat] = instflow(BfMat, varargin)
%INSTEST

import tools.dirprompt tools.varorfile tools.loadadv tools.advdouble tools.saveadv
import flow2.instdoppler

% BfMat = varorfile(inPath, @loadadv);
% metadata = BfMat.meta;

BfMat = double(BfMat);

% if nargin > 2
%     outDir = dirprompt(varargin{2});
% elseif isa(inPath, 'char')
%     outDir = fileparts(inPath);
% else
%     outDir = './';
% end

if nargin > 1
    if isa(varargin{1}, 'containers.Map')
        map = varargin{1};
    else
        keys = varargin(1:2:end);
        values = varargin(2:2:end);
        map = containers.Map(keys, values);
    end
else
    map = containers.Map;
end

if isKey(map, 'window')
    window = map('window');
else
    window = 'rectwin';
end
if isKey(map, 'averaging')
    averaging = map('averaging');
else
    averaging = 0;
end
if isKey(map, 'resample')
    resample = map('resample');
else
    resample = 1;
end

[nSample, nFrame, nPos] = size(BfMat);

if resample > 1
    
    BfMatInterp = zeros(nSample*resample, nPos, nFrame);
    
    for pos = 1:nPos
        
        for frame = 1:nFrame
            BfMatInterp(:,frame,pos) = interp(BfMat(:,frame,pos), resample);
        end
    end
    
    BfMat = BfMatInterp;
    nSample = nSample*resample;
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

% VelMat = advdouble(instdoppler(BfMat, map), {'estimate', 'frame', 'position'});
VelMat = instdoppler(BfMat, map);

% VelMat.meta = metadata;
% VelMat.meta.window = win;
% VelMat.meta.averaging = averaging;
% VelMat.meta.resample = resample;

% if nargout == 0
%     
%     fileNumber = metadata.fileNumber;
%     volumeNumber = metadata.volumeNumber;
%     outPath = fullfile(outDir, ['ve_' sprintf('%0.4d', fileNumber) ...
%         '_' sprintf('%0.4d', volumeNumber)]);
%     
%     saveadv(outPath, VelMat);
% end

