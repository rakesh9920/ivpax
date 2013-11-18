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

TaskList = Log(Log.COMPLETE == false,:);
nTask = height(TaskList);

% create job and new task for each unprocessed file

Job = createJob(parcluster);

for task = 1:nTask
   
    fHandle = str2func(cell2mat(TaskList{task, 'FUNCTION'}));
    nArgOut = TaskList{task, 'NARGOUT'};
    ArgIn = cell(TaskList{task, 'ARGIN'});

    createTask(Job, fHandle, nArgOut, ArgIn);
end

% submit jobs


end

function TableOut = parsecsv(TableIn)

	nRows = height(TableIn);
	ArgIn = cell(nRows, 1);

	for row = 1:nRows

		nArgIn = TableIn{row, 'NARGIN'};
		ArgIn{row} = {TableIn{row, 4:(4 + nArgIn - 1)}};
	end

	TableOut = table(TableIn.FUNCTION, TableIn.NARGOUT, ArgIn, TableIn.COMPLETE);
end