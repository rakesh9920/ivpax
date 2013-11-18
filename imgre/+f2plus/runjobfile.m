function [Job] = runjobfile(jobFile)
%
%

import tools.loadmat
import f2plus.run_sim_multi

% read jobFile and list unprocessed files

[~, ~, ext] = fileparts(jobFile);

switch ext
    case {'.csv', '.txt'}
        Log = readtable(jobFile);
    case '.mat'
        Log = loadmat(jobFile); 
end

TaskList = Log(Log.PROCESSED == false,:);
nTask = height(TaskList);

% create job and new task for each unprocessed file

Job = createJob(parcluster);

for task = 1:nTask
   
    fHandle = str2func(cell2mat(TaskList{task, 'FUNCTION'}));
    nOutputArgs = TaskList{task, 'NOUTPUTARG'};
    InputArgs = cell(TaskList{task, 'INPUTARGS'});

    createTask(Job, fHandle, nOutputArgs, InputArgs);
end

% submit jobs


end

