function [] = grouprf(inPath, framesPerGroup)
%

import tools.loadmeta

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

% scan directory for rf files and create listing
Listing = struct2cell(dir(strcat(inPath, '/sct_*')));
nFiles = size(Listing, 2);
FileNames = strcat(repmat(inPath, [nFiles 1]), '/', Listing(1,:).');

% check if filenames is empty

% load metadata for all rf files
MetaData = struct2table(cellfun(@loadmeta, FileNames));
MetaData.filePath = FileNames;

nFrames = max(MetaData.endFrame);
nGroups = ceil(nFrames/framesPerGroup);
sampleFreq = MetaData{1,sampleFrequency};

for group = 1:nGroups
    
    startFrame = framesPerGroup*(group - 1) + 1;
    endFrame = framesPerGroup*group;
    idx = (MetaData.startFrame <= endFrame & MetaData.endFrame >= startFrame);
    GroupMeta = MetaData(idx,:);
    
    lateTime = max(GroupMeta{:,'startTime'} + GroupMeta{:,'numberOfSamples'}./sampleFreq);
    earlyTime = min(GroupMeta.startTime);
    
    minSamples = ceil((lateTime - earlyTime)*sampleFreq);
    
end



end
