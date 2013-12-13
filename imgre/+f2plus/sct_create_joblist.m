function [jobList] = sct_create_joblist(func, def, inPath)
% Searches a directory for sct files and creates a job with tasks assigned
% to process each file.

if isa(func, 'char')
   func = str2func(func); 
end

if isa(def, 'char')
   def = str2func(def); 
end

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

Listing = struct2cell(dir(strcat(inPath, '/sct_*')));
Files = Listing(1,:).';

nFiles = size(Files, 1);

TASKNUMBER = (1:nFiles).';
FUNCTION = repmat({func}, [nFiles 1]);
NARGOUT = zeros(nFiles, 1);
NARGIN = ones(nFiles, 1).*2;
ARGIN = cat(2, repmat({def}, [nFiles 1]), Files);
COMPLETE = false(nFiles, 1);

jobList = table(TASKNUMBER, FUNCTION, NARGOUT, NARGIN, ARGIN, COMPLETE);

end

