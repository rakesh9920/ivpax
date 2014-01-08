function [jobList] = sct_create_joblist(func, def, inDir, varargin)
%SCT_CREATE_JOBLIST Searches a directory for sct files and creates a job
% with tasks assigned to process each file.

import tools.dirprompt tools.querydir

if isa(func, 'char')
   func = str2func(func); 
end

if isa(def, 'char')
   def = str2func(def); 
end

inDir = dirprompt(inDir);

if nargin > 3
    outDir = dirprompt(varargin{1});
else
    outDir = inDir;
end

[FilePaths, nFiles] = querydir(inDir, 'sct_');
% Listing = struct2cell(dir(strcat(inDir, 'sct_*')));
% Files = cellfun(@(x) strcat(inDir, '/', x), Listing(1,:).', 'UniformOutput', false);
% nFiles = size(Files, 1);

TASKNUMBER = (1:nFiles).';
FUNCTION = repmat({func}, [nFiles 1]);
NARGOUT = zeros(nFiles, 1);
NARGIN = ones(nFiles, 1).*2;
ARGIN = cat(2, repmat({def}, [nFiles 1]), FilePaths, repmat({outDir}, [nFiles 1]));
%     repmat({strcat(outDir, '/')}, [nFiles 1]));
COMPLETE = false(nFiles, 1);

jobList = table(TASKNUMBER, FUNCTION, NARGOUT, NARGIN, ARGIN, COMPLETE);

end

