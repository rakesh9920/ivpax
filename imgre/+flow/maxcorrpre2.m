function [BfMatOut] = maxcorrpre2(inFile, outDir, TxPos, RxPos, FieldPos, ...
    nCompare, deltaSample, nWindowSample, varargin)
% velocity estimate along axial direction
% bfmethod, recombine, progress

import beamform.gfbeamform4 beamform.gtbeamform
import tools.uigetfile_n_dir tools.upicbar

% read in optional arguments
if nargin > 8
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
if isKey(map, 'recombine')
    recombine = map('recombine');
else
    recombine = false;
end
if isKey(map, 'bfmethod')
    bfmethod = map('bfmethod');
else
    bfmethod = 'time';
end
if isKey(map, 'filename')
    outFilename = map('filename');
else
    outFilename = 'PRE';
end
if isKey(map, 'resample')
    resample = map('resample');
else
    resample = 1;
end
if isKey(map, 'averaging')
    averaging = map('averaging');
else
    averaging = 0;
end

% set window and number of compare points to be odd
if mod(nWindowSample, 2) == 0
    nWindowSample = nWindowSample + 1;
end
if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end

if isempty(inFile)
    inFile = uigetfile_n_dir('', 'Select input file(s)');
end

if nargout > 0
    argout = true;
elseif isempty(outDir)
    argout = false;
    outDir = uigetdir('','Select output directory');
end

if outDir(end) ~= '/'
    outDir = strcat(outDir, '/');
end

if ~isa(inFile, 'cell')
    inFile = {inFile};
end

nFile = length(inFile);

if argout || recombine
    BfMatOut = cell(1, nFile);
end

nFieldPos = size(FieldPos, 2);

nSample = (nCompare - 1)*deltaSample + nWindowSample;
pointNo = (nCompare + 1)/2;
centerSample = (nSample + 1)/2;

if progress
    prog = upicbar('Preprocessing...');
end

% iterate over files
for file = 1:nFile
    
    filename = inFile{file};
    Mat = load(filename);
    fields = fieldnames(Mat);
    RxSigMat = Mat.(fields{1});
    
    % beamform
    switch bfmethod
        case 'time'
            BfMat = gtbeamform(RxSigMat, TxPos, RxPos, FieldPos, ...
                nSample, mapOut);
        case 'frequency'
            BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, ...
                nSample, mapOut);
    end
    
    BfMat = permute(shiftdim(BfMat, -1), [2 1 4 3]);
    
    nFrame = size(BfMat, 3);
    
    % apply sliding average
    
    if averaging > 1
        BfMatAvg = zeros(nSample, 1, nFrame - averaging + 1, nFieldPos);
        
        for frame = 1:(nFrame - averaging + 1)
            BfMatAvg(:,:,frame,:) = sum(BfMatWin(:,:,frame:(frame+averaging-1),:),3);
        end
        
        BfMat = BfMatAvg;
    end
    
    % resample BF data if desired
    if resample > 1
        
        %         BfMatInterp = interp(BfMat(:), resample);
        %         BfMat = reshape(BfMatInterp, [], 1, nFrame, nFieldPos);
        
        BfMatInterp = zeros(nSample*resample, 1, nFrame, nFieldPos);
        
        for pos = 1:nFieldPos
            for frame = 1:nFrame
                BfMatInterp(:,1,frame,pos) = interp(BfMat(:,1,frame,pos), resample);
            end
        end
        
        BfMat = BfMatInterp;
    end
    
    % divide BF data into windowed segments
    BfMatWin = zeros(nWindowSample, nCompare, nFrame, nFieldPos);
    
    for point = 1:nCompare
        
        center = (point - pointNo)*deltaSample + centerSample;
        startSample = center - (nWindowSample - 1)/2;
        endSample = center + (nWindowSample - 1)/2;
        
        BfMatWin(:,point,:,:) = BfMat(startSample:endSample,:,:,:);
    end
    
    if argout || recombine
        BfMatOut{file} = BfMatWin;
    else
        BfMat = BfMatWin;
        save(strcat(outDir, outFilename, sprintf('%0.4d', file)), 'BfMat');
    end
    
    if progress
        upicbar(prog, file/nFile);
    end
end

if recombine
    BfMat = cat(3, BfMatOut{:});
    save(strcat(outDir, outFilename), 'BfMat', '-v7.3');
end

