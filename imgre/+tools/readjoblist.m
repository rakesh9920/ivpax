function [Job] = readjoblist(jobFile, varargin)
% Creates a job with tasks based on a job file and submits it to the local
% parallel cluster.

import tools.loadfirstvar

if nargin > 1
    AttachedFiles = varargin{1};
else
    AttachedFiles = {};
end

% read jobFile and list unprocessed files
if isa(jobFile, 'char')
    
    [~, ~, ext] = fileparts(jobFile);
    
    switch ext
        case {'.csv', '.txt'}
            Log = readtable(jobFile);
            Log = parsecsv(Log);
        case '.mat'
            Log = loadfirstvar(jobFile);
    end
else
    
    Log = jobFile;
end

TaskList = Log(Log.COMPLETE == false,:);
nTask = height(TaskList);

% create job and new task for each unprocessed file
Job = createJob(parcluster);
%Job.AutoAttachFiles = false;
Job.AttachedFiles = AttachedFiles;

for task = 1:500
    
    fHandle = TaskList{task, 'FUNCTION'};
    nArgOut = TaskList{task, 'NARGOUT'};
    ArgIn = TaskList{task, 'ARGIN'};
    createTask(Job, fHandle, nArgOut, ArgIn);
    %createTask(Job, fHandle, nArgOut, reshape(ArgIn.', [1 2000]));
end

% submit jobs

end

function TableOut = parsecsv(TableIn)

nRows = height(TableIn);
ArgIn = cell(nRows, 1);
Complete = zeros(nRows, 1);

for row = 1:nRows
    
    nArgIn = TableIn{row, 'NARGIN'};
    
    for arg = 1:nArgIn
        ArgIn{row} = cat(2, ArgIn{row}, TableIn{row, 4 + arg - 1});
    end
    
    if isa(TableIn.COMPLETE{row},'char')
        Complete(row) = strcmpi(TableIn.COMPLETE{row}, 'true');
    else
        Complete(row) = TableIn.COMPLETE{row};
    end
end

FUNCTION = cellfun(@str2fuc, TableIn.FUNCTION);
TableOut = table(FUNCTION, TableIn.NARGOUT, TableIn.NARGIN, ArgIn, ...
    Complete);
TableOut.Properties.VariableNames = {'FUNCTION', 'NARGOUT', 'NARGIN', 'ARGIN',...
    'COMPLETE'};
end


