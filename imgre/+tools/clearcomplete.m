function [] = clearcomplete(jobs, joblist)
%CLEARCOMPLETE Summary of this function goes here


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

completeJobs = cellfun(@(x) x.State, jobs, 'UniformOutput', false);

end

