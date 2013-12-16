function [] = grouprf(inPath, framesPerGroup)
% Searches directory for RF files and align, sums, and groups RF data based
% on their corresponding frames and start times.

import tools.loadvar
import tools.saveadv
import tools.loadadv
import tools.alignsumrf

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

% scan directory for rf files and create listing
Listing = struct2cell(dir(strcat(inPath, '/rf_*')));

if isempty(Listing)
   error('no RF files found in directory'); 
end

nFiles = size(Listing, 2);
FileNames = strcat(repmat(inPath, [nFiles 1]), '/', Listing(1,:).');

% check if filenames is empty

% load metadata for all rf files
MetaData = struct2table(cellfun(@(x) loadvar(x, 'meta'), FileNames));
MetaData.filePath = FileNames;

nFrames = max(MetaData.endFrame);
nGroups = ceil(nFrames/framesPerGroup);

for group = 1:nGroups
    
    % find files that have frames belonging in the group
    startFrame = framesPerGroup*(group - 1) + 1;
    endFrame = min(framesPerGroup*group, nFrames);
    idx = (MetaData.startFrame <= endFrame & MetaData.endFrame >= startFrame);
    GroupMetaData = MetaData(idx,:);
    
    % preallocate based on minimum number of samples required
    % lateTime = max(GroupMeta{:,'startTime'} + GroupMeta{:,'numberOfSamples'}...
    % ./sampleFreq);
    % earlyTime = min(GroupMeta.startTime);
    % minSamples = ceil((lateTime - earlyTime)*sampleFreq);
    % RfMat = advdouble(zeros(minSamples, nChannels, framesPerGroup), ..
    % {'sample','channel','frame'});
    
    % load first file
    RfMat = loadadv(cell2mat(GroupMetaData{1, 'filePath'}));
    frontFrame = max(RfMat.meta.startFrame, startFrame);
    backFrame = min(RfMat.meta.endFrame, endFrame);
    RfMat = RfMat('frame', frontFrame:backFrame);
    
    for file = 2:size(GroupMetaData, 1)
        
        % load file and find frames in group
        FileRfMat = loadadv(cell2mat(GroupMetaData{file, 'filePath'}));
        frontFrame = max(FileRfMat.meta.startFrame, startFrame);
        backFrame = min(FileRfMat.meta.endFrame, endFrame);
        
        RfMat = RfMat + FileRfMat('frame', frontFrame:backFrame);
    end
    
    % set metadata for RfMat
    RfMat.meta.fileNumber = group;
    RfMat.meta.startFrame = startFrame;
    RfMat.meta.endFrame = endFrame;
    outPath = strcat(inPath, '/', 'rfg_', sprintf('%0.4d', group));
    saveadv(outPath, RfMat);
end



end
