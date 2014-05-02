function [] = daq2mat(inDir, outDir, varargin)

import tools.upicbar tools.bandpass
import containers.Map

% read in optional arguments
if nargin > 2
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
if isKey(map, 'channels')
    Channels = map('channels');
else
    Channels = 0:127;
end
if isKey(map, 'nframe')
    nFrame = map('nframe');
else
    nFrame = 100;
end
if isKey(map, 'reroute')
    reroute = map('reroute');
else
    reroute = true;
end
if isKey(map, 'progress')
    progress = map('progress');
    mapOut('progress') = false;
else
    progress = false;
end
if isKey(map, 'filter')
    filter = map('filter');
    fc = map('fc');
    bw = map('bw');
else
    filter = false;
end

global SAMPLE_FREQUENCY
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end

if isempty(inDir)
    inDir = uigetdir('', 'Select input directory');
end

if isempty(outDir)
    outDir = uigetdir('', 'Select output directory');
end

if inDir(end) ~= '/'
    inDir = strcat(inDir, '/');
end

if outDir(end) ~= '/'
    outDir = strcat(outDir, '/');
end

if reroute
    Route = [0:8:127 1:8:127 2:8:127 3:8:127 4:8:127 ...
        5:8:127 6:8:127 7:8:127 8:8:127];
else
    Route = 0:127;
end

fid = fopen(strcat(inDir, 'CH000.daq'), 'r');
Header = fread(fid, 3, 'int32');
fclose(fid);

nFramePerFile = Header(2);
nSamplePerFrame = Header(3);
nChannel = length(Channels);

nChunk = floor(nFramePerFile/nFrame);

if nChunk == 0
    nFrame = nFramePerFile;
    nChunk = 1;
end

if progress
    upic = upicbar('Converting DAQ data...');
end

for chunk = 1:nChunk
    
    RfMat = zeros(nChannel, nSamplePerFrame, nFrame, 'int16');
    startFrame = (chunk - 1)*nFrame + 1;
    
    for ch = Channels
        
        RfData = readdaq(inDir, Route(ch+1), startFrame, nFrame, nSamplePerFrame);
        RfMat(ch+1,:,:) = reshape(RfData, 1, nSamplePerFrame, []);
    end
    
    if filter
        RfMatF = bandpass(double(RfMat), 2, fc, bw, SAMPLE_FREQUENCY);
        save(strcat(outDir, sprintf('RFF%0.4d', chunk)), 'RfMatF');
    else
        save(strcat(outDir, sprintf('RF%0.4d', chunk)), 'RfMat');
    end
    
    if progress
        upicbar(upic, chunk/nChunk);
    end
end

if mod(nFramePerFile, nFrame) > 0 && nFramePerFile > nFrame
    
    nFrame = mod(nFramePerFile, nFrame);
    
    RfMat = zeros(nChannel, nSamplePerFrame, nFrame, 'int16');
    startFrame = nChunk*nFrame + 1;
    
    for ch = Channels
        
        RfData = readdaq(inDir, Route(ch+1), startFrame, nFrame, nSamplePerFrame);
        RfMat(ch+1,:,:) = reshape(RfData, 1, nSamplePerFrame, []);
    end
    
    if filter
        RfMatF = bandpass(double(RfMat), 2, fc, bw, SAMPLE_FREQUENCY);
        save(strcat(outDir, sprintf('RFF%0.4d',(nChunk + 1))), 'RfMatF');
    else
        save(strcat(outDir, sprintf('RF%0.4d',(nChunk + 1))), 'RfMat');
    end
end

end

function [RfData] = readdaq(inDir, channel, startFrame, nFrame, nSamplePerFrame)

if channel > 99
    numstr = num2str(channel);
elseif channel > 9
    numstr = strcat('0', num2str(channel));
else
    numstr = strcat('00', num2str(channel));
end

filename = strcat(inDir, 'CH', numstr, '.daq');

fid = fopen(filename, 'r');

fseek(fid, (12 + (startFrame - 1)*nSamplePerFrame*2), 'bof');
RfData = fread(fid, nFrame*nSamplePerFrame, 'int16');

fclose(fid);
end