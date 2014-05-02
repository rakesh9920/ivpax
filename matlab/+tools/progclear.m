function [] = progclear()
%PROGCLEAR

if isunix
    tmp = '/home/bshieh/tmp/';
else
    tmp = tempdir;
end

if exist([tmp 'prog/'], 'dir')
    rmdir([tmp 'prog/'], 's');
end

end

