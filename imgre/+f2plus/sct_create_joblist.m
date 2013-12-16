function [jobList] = sct_create_joblist(func, def, inPath, varargin)
% Searches a directory for sct files and creates a job with tasks assigned
% to process each file.

if isa(func, 'char')
   func = str2func(func); 
end

if isa(def, 'char')
   def = str2func(def); 
end

if nargin > 3
    outPath = varargin{1};
    
    if isempty(outPath)
        outPath = uigetdir('','Select an output directory');
    end
else
    
    outPath = inPath;
end

if outPath(end) == '/'
    outPath(end) = [];
end

if isempty(inPath)
    inPath = uigetdir('','Select an input directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

Listing = struct2cell(dir(strcat(inPath, '/sct_*')));
Files = cellfun(@(x) strcat(inPath, '/', x), Listing(1,:).', 'UniformOutput', false);
nFiles = size(Files, 1);

TASKNUMBER = (1:nFiles).';
FUNCTION = repmat({func}, [nFiles 1]);
NARGOUT = zeros(nFiles, 1);
NARGIN = ones(nFiles, 1).*2;
ARGIN = cat(2, repmat({def}, [nFiles 1]), Files, ...
    repmat({strcat(outPath, '/')}, [nFiles 1]));
COMPLETE = false(nFiles, 1);

jobList = table(TASKNUMBER, FUNCTION, NARGOUT, NARGIN, ARGIN, COMPLETE);

end

