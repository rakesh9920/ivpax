function [FiltDataOut] = bandpass(RfData, dim, f1, f2, fs, varargin)

import tools.upicbar

if nargin > 5
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

if isKey(map, 'progress')
    progress = map('progress');
    map('progress') = false;
else
    progress = false;
end

% design chebyshev type 2 bandpass filter
% f1 = (fc - bw/2)/(fs/2);
% f2 = (fc + bw/2)/(fs/2);
ff1 = f1/fs/2;
ff2 = f2/fs/2;
%[b, a] = cheby2(18, 120, [f1 f2]); % 60dB attenuation, 12th order
%[z, p, k] = cheby2(18, 120, [f1 f2]);
[z, p, k] = butter(6, [ff1 ff2]);
[sos, g] = zp2sos(z,p,k);

CellData = num2cell(RfData, dim);
cellSize = size(CellData);
FiltData = cell(cellSize);
nInd = numel(CellData);

if progress
    upic = upicbar('Filtering...');
end

for ind = 1:nInd
    
    %sub = cell(1,3);
    %[sub{:}] = ind2sub(cellSize, ind);
    
    FiltData{ind} = filtfilt(sos, g, double(CellData{ind})); 
    
    if progress
        upicbar(upic, ind/nInd);
    end
end

FiltDataOut = cell2mat(FiltData);


