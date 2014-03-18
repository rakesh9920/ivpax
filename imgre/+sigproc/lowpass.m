function [FiltDataOut] = lowpass(RfData, dim, fh, fs, varargin)

import tools.upicbar

if nargin > 4
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

% design chebyshev type 2 lowpass filter
%[b, a] = cheby2(18, 120, fh/(fs/2)); % 60dB attenuation, 12th order
[z, p, k] = butter(6, fh/(fs/2), 'low');
%[z, p, k] = cheby2(18, 120, fh/(fs/2), 'low');
[sos,g] = zp2sos(z,p,k);

CellData = num2cell(RfData, dim);
cellSize = size(CellData);
FiltData = cell(cellSize);
nInd = numel(CellData);

if progress
    upic = upicbar('Filtering...');
end

for ind = 1:nInd
    
    sub = cell(1,3);
    [sub{:}] = ind2sub(cellSize, ind);
    
    FiltData{ind} = filtfilt(sos, g, double(CellData{ind})); 
    
    if progress
        upicbar(upic, ind/nInd);
    end
end

FiltDataOut = cell2mat(FiltData);


