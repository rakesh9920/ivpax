function [VelEstOut, BfSigMatAvg] = corrlagest(inFile, varargin)
%
% window, averaging, progress

import flow.lagdoppler
import tools.uigetfile_n_dir tools.upicbar

% read in optional arguments
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

% make deep copy of map for passing to other functions
mapOut = [map; containers.Map()] ;

% pull needed map values
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
if isKey(map, 'progress')
    progress = map('progress');
    mapOut('progress') = false;
else
    progress = false;
end

% select input files and put into cell array
if isempty(inFile)
    inFile = uigetfile_n_dir('', 'Select input file(s)');
end
if ~isa(inFile, 'cell')
    inFile = {inFile};
end
nFile = length(inFile);

VelEst = cell(nFile);

if progress
    prog = upicbar('Estimating velocity...');
end

% iterate over each file
for file = 1:nFile
    
    % load file and read first field
    filename = inFile{file};
    Mat = load(filename);
    fields = fieldnames(Mat);
    BfSigMat = Mat.(fields{1});
    
    [nWindowSample, nFieldPos, nFrame] = size(BfSigMat);
    
    switch window
        case 'hanning'
            win = hanning(nWindowSample);
        case 'gausswin'
            win = gausswin(nWindowSample);
        case 'rectwin'
            win = rectwin(nWindowSample);
    end
    
    % apply window to RF data
    BfSigMatWin = bsxfun(@times, BfSigMat, win);
    
    % apply running average and then perform velocity estimation
    if averaging > 1
        BfSigMatAvg = zeros(nWindowSample, nFieldPos, nFrame - averaging + 1);
        
        for frame = 1:(nFrame - averaging + 1)
            BfSigMatAvg(:,:,frame) = sum(BfSigMatWin(:,:,frame:(frame+averaging-1)),3);
        end
        
        VelEst{file} = lagdoppler(BfSigMatAvg, mapOut);
    else
        
        BfSigMatAvg = [];
        VelEst{file} = lagdoppler(BfSigMatWin, mapOut);
    end
    
    if progress
        upicbar(prog, file/nFile);
    end
end

% cat estimates from each file into one array
VelEstOut = cat(2, VelEst);
VelEstOut = VelEstOut{:};


