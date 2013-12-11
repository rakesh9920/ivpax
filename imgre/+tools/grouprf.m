function [] = grouprf(inPath, framesPerGroup)
%

import tools.loadvar
import tools.saveadv
import tools.advdouble

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
MetaData = struct2table(cellfun(@loadvar, FileNames, 'meta'));
MetaData.filePath = FileNames;

nFrames = max(MetaData.endFrame);
nGroups = ceil(nFrames/framesPerGroup);
nChannels = MetaData{1,numberOfChannels};
sampleFreq = MetaData{1,sampleFrequency};

for group = 1:nGroups
    
    % find files that belong in the group
    startFrame = framesPerGroup*(group - 1) + 1;
    endFrame = framesPerGroup*group;
    idx = (MetaData.startFrame <= endFrame & MetaData.endFrame >= startFrame);
    GroupMeta = MetaData(idx,:);
    
    % preallocate based on minimum number of samples required 
    lateTime = max(GroupMeta{:,'startTime'} + GroupMeta{:,'numberOfSamples'}./sampleFreq);
    earlyTime = min(GroupMeta.startTime);
    minSamples = ceil((lateTime - earlyTime)*sampleFreq);
    RfMat = advdouble(zeros(minSamples, nChannels, framesPerGroup), {'sample','channel','frame'});
    
    for file = 1:size(GroupMeta, 1)
        
        % load file
        RfData = loadadv(GroupMeta{file, 'filePath'});
        startTime = RfData.meta.startTime;
        numberOfSamples = RfData.meta.numberOfSamples;
        frontFrame = max(RfData.meta.startFrame, startFrame);
        backFrame = min(RfData.meta.endFrame, endFrame);
        
        % pad zeros in front and back
        frontPad = round((startTime - earlyTime)*sampleFreq);
        RfData = padarray(RfData, [frontPad 0 0], 'pre');
        RfData = padarray(RfData, [minSamples - size(RfData, 1) 0 0], 'post');
        
        % add to total
        RfMat('frame',frontFrame:backFrame) = RfMat('frame',frontFrame:backFrame) + RfData;
    end
    
    % set metadata for RfMat
    
    
end



end
