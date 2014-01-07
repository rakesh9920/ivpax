function [] = grouprf(inPath, framesPerGroup)
% Searches directory for RF files and align, sums, and groups RF data based
% on their corresponding frames and start times.

import tools.loadvar tools.saveadv tools.loadadv tools.alignsumrf tools.querydir

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

[FileNames, nFiles] = querydir(inPath, 'rf_');

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
    
    % load rf data from these files
    RfMats = cellfun(@loadadv, GroupMetaData{:,'filePath'}, 'UniformOutput', false);
    
    % align files wrt sample and frame and sum
    RfMatOut = alignsumrf(RfMats{:});
    RfMatOut.label = {'rf', 'channel', 'frame'};
    
    % only save the frames assigned to this group
    front = startFrame - RfMatOut.meta.startFrame + 1;
    back = front + endFrame - startFrame;
    outPath = strcat(inPath, '/', 'rf_', sprintf('%0.4d', group));
    saveadv(outPath, RfMatOut('frame', front:back));
end



end