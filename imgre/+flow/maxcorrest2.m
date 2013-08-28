function [VelEstOut, BfMatAvg, XcorrMat] = maxcorrest2(inFile, nPoint, nDeltaSample, varargin)
%
% window, averaging, progress

import flow.ftdoppler2
import tools.uigetfile_n_dir tools.upicbar

% read in optional arguments
if nargin > 3
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
if isKey(map, 'progress')
    progress = map('progress');
    mapOut('progress') = false;
else
    progress = false;
end
if isKey(map, 'averaging')
    averaging = map('averaging');
else
    averaging = 0;
end
if isKey(map, 'window')
    window = map('window');
else
    window = 'rectwin';
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

pointNo = (nPoint + 1)/2;

if progress
    prog = upicbar('Estimating  velocity...');
end

% iterate over each file
for file = 1:nFile
    
    % load file and read first field
    filename = inFile{file};
    Mat = load(filename);
    fields = fieldnames(Mat);
    BfSigMat = Mat.(fields{1});
    
    [nWindowSample, nFieldPos, nFrame] = size(BfSigMat);
    
    BfSigMat2 = zeros(nWindowSample, nPoint, nFrame, nFieldPos);
    
    switch window
        case 'hanning'
            win = hanning(nWindowSample);
        case 'gausswin'
            win = gausswin(nWindowSample);
        case 'rectwin'
            win = rectwin(nWindowSample);
    end
    
    % apply window to RF data
    BfMatWin = bsxfun(@times, BfSigMat, win);
    
    
        
    % apply running average and then perform velocity estimation
    if averaging > 1
        BfMatAvg = zeros(nWindowSample, nPoint, nFrame - averaging + 1, nFieldPos);
        
        for frame = 1:(nFrame - averaging + 1)
            BfMatAvg(:,:,frame,:) = sum(BfMatWin(:,:,frame:(frame+averaging-1),:),3);
        end
        
        [VelEst{file}, XcorrMat] = ftdoppler2(BfMatAvg, nDeltaSample, pointNo, mapOut);
    else
        [VelEst{file}, XcorrMat] = ftdoppler2(BfMatWin, nDeltaSample, pointNo, mapOut);
    end
    
    if progress
        upicbar(prog, file/nFile);
    end
end

VelEstOut = cat(2, VelEst);
VelEstOut = VelEstOut{:};