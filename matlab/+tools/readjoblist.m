function [Jobs] = readjoblist(joblist, varargin)
% Creates a job with tasks based on a job file and submits it to the local
% parallel cluster.

import tools.loadfirstvar

if nargin > 1
    AttachedFiles = varargin{1};
else
    AttachedFiles = {};
end

% read jobFile and list unprocessed files
if isa(joblist, 'char')
    
    [~, ~, ext] = fileparts(joblist);
    
    switch ext
        case {'.csv', '.txt'}
            Log = readtable(joblist);
            Log = parsecsv(Log);
        case '.mat'
            Log = loadfirstvar(joblist);
    end
else
    
    Log = joblist;
end

TaskList = Log(Log.COMPLETE == false,:);
nTasks = height(TaskList);

% create job and new task for each unprocessed file
tasksPerJob = 24;
nJobs = ceil(nTasks/tasksPerJob);
Jobs = cell(1, nJobs);

for ijob = 1:nJobs
    
    Jobs{ijob} = createJob(parcluster);
    Jobs{ijob}.AttachedFiles = AttachedFiles;
    
    if ijob == nJobs
        kTasks = nTasks - tasksPerJob*(nJobs - 1);
    else
        kTasks = tasksPerJob;
    end
    
    for task = 1:kTasks
        
        idx = tasksPerJob*(ijob - 1) + task;
        fHandle = TaskList{idx, 'FUNCTION'};
        nArgOut = TaskList{idx, 'NARGOUT'};
        ArgIn = TaskList{idx, 'ARGIN'};
        createTask(Jobs{ijob}, fHandle, nArgOut, ArgIn);
    end
end

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


