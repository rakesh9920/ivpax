function [jobList] = sct_create_job(func, def, inPath)
%

if isa(func, 'char')
   func = str2func(func); 
end

if isa(def, 'char')
   def = str2func(def); 
end

if isempty(inPath)
    inPath = uigetdir('','Select an output directory');
end

if inPath(end) == '/'
    inPath(end) = [];
end

Listing = struct2cell(dir(strcat(inPath, '/rf_*')));
Files = Listing(1,:).';


nFiles = size(Files, 1);

TASKNUMBER = (1:nFiles).';
FUNCTION = repmat({func}, [nFiles 1]);
NARGOUT = zeros(nFiles, 1);
NARGIN = ones(nFiles, 1).*2;
ARGIN = cat(2, repmat({def}, [nFiles 1]), Files);
COMPLETE = repmat({false}, [nFiles 1]);

jobList = table(TASKNUMBER, FUNCTION, NARGOUT, NARGIN, ARGIN, COMPLETE);

end

