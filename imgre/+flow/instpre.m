function [BfMatOut] = instpre(inFile, outDir, TxPos, RxPos, FieldPos, ...
    nWindowSample, varargin)
%
% bfmethod, recombine, progress

import beamform.gfbeamform4 beamform.gtbeamform
import tools.uigetfile_n_dir tools.upicbar

% read in optional arguments
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

% make deep copy of map for passing to other functions
mapOut = [map; containers.Map()] ;

% pull needed map values
if isKey(map, 'bfmethod')
    bfmethod = map('bfmethod');
else
    bfmethod = 'time';
end
if isKey(map, 'recombine')
    recombine = map('recombine');
else
    recombine = false;
end
if isKey(map, 'progress')
    progress = map('progress');
    mapOut('progress') = false;
else
    progress = false;
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

if mod(nWindowSample, 2) == 0
    nWindowSample = nWindowSample + 1;
end

if isempty(inFile)
    inFile = uigetfile_n_dir('', 'Select input file(s)');
end

if nargout > 0
    argout = true;
else 
    argout = false;
    if isempty(outDir)
        outDir = uigetdir('','Select output directory');
    end
end

if outDir(end) ~= '/'
    outDir = strcat(outDir, '/');
end

if ~isa(inFile, 'cell')
    inFile = {inFile};
end

nFile = length(inFile);

if argout || recombine
    BfMatOut = cell(nFile);
end

if progress
    prog = upicbar('Preprocessing...');
end

for file = 1:nFile
    
    filename = inFile{file};
    Mat = load(filename);
    fields = fieldnames(Mat);
    RxSigMat = Mat.(fields{1});
    
    switch bfmethod
        case 'time'
            BfMat = gtbeamform(RxSigMat, TxPos, RxPos, FieldPos, ...
                nWindowSample, mapOut);
        case 'frequency'
            BfMat = gfbeamform4(RxSigMat, TxPos, RxPos, FieldPos, ...
                nWindowSample, mapOut);
    end
    
    [nSample, nFieldPos, nFrame] = size(BfMat);
    
    if resample > 1
       
        BfMatInterp = zeros(nSample*resample, nFieldPos, nFrame);
       
       for pos = 1:nFieldPos
           for frame = 1:nFrame
               BfMatInterp(:,pos,frame) = interp(BfMat(:,pos,frame), resample);
           end
       end
       
       BfMat = BfMatInterp;
    end
    
    if argout || recombine
        BfMatOut{file} = BfMat;
    else
        save(strcat(outDir, outFilename, sprintf('%0.4d', file)), 'BfMat');
    end
    
    if progress
        upicbar(prog, file/nFile);
    end
end

if recombine
    BfMat = cat(3, BfMatOut{:});
    save(strcat(outDir, outFilename), 'BfMat');
end

