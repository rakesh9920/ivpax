function [jobList] = makejoblist(fun, def, inDir, nSections, varargin)
%MAKEJOBLIST 
%

import tools.querydir tools.dirprompt

if isa(fun, 'char')
    fun = str2func(fun);
end

inDir = dirprompt(inDir);

if nargin > 4
    outDir = dirprompt(varargin{1});
else
    outDir = inDir;
end

[FilePaths, nFiles] = querydir(inDir, 'rf_');
nTasks = nFiles*nSections;

TASKNUMBER = (1:nTasks).';
FUNCTION = repmat({fun}, [nTasks 1]);
NARGOUT = zeros(nTasks, 1);
NARGIN = ones(nTasks, 1).*5;

ARG1 = repmat({def}, [nTasks 1]);
RepFiles = repmat(FilePaths, [1 nSections]).';
ARG2 = RepFiles(:);
ARG3 = repmat(num2cell(1:nSections).', [nFiles 1]);
ARG4 = repmat({nSections}, [nTasks 1]);
ARG5 = repmat({outDir}, [nTasks 1]);
ARGIN = cat(2, ARG1, ARG2, ARG3, ARG4, ARG5);

COMPLETE = false(nTasks, 1);

jobList = table(TASKNUMBER, FUNCTION, NARGOUT, NARGIN, ARGIN, COMPLETE);
end

