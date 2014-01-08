function [outDir] = dirprompt(inPath)
% If input is empty, prompts user to select a directory.  Otherwise, parses
% path string for deliminter and returns corrected string.  The directory
% is created if it does not already exist.

if isempty(inPath)
    
    outDir = uigetdir('', 'select a directory');
else
    
    outDir = inPath;
    if inPath(end) ~= '/'
        outDir = strcat(inPath, '/');
    end
end

if ~exist(outDir, 'dir')
    mkdir(outDir);
end

end

