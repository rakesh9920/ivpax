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

if mod(nWindowSample, 2) == 0
    nWindowSample = nWindowSample + 1;
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
    BfMatOut = cell(nFile);
end

if progress
    prog = upicbar('Preprocessing...');
    upicbar(prog, 0);
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
    
    if argout || recombine
        BfMatOut{file} = BfMat;
    else
        save(strcat(outDir, sprintf('PRE%0.4d', file)), 'BfMat');
    end
    
    if progress
        upicbar(prog, file/nFile);
    end
end

if recombine
    BfMat = cat(3, BfMatOut{:});
    save(strcat(outDir, 'PRE1'), 'BfMat');
end

