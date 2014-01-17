function [] = progdisp()
%PROGDISP

import tools.querydir

progDir = [tempdir 'prog/'];

[progFiles, nFiles] = querydir(progDir, '');

nChars = 0;
while true
    
    [percentDone, timeLeft, barTitle] = cellfun(@progread, progFiles, ...
        'UniformOutput', false);
    
    fullStr = '';
    for file = 1:nFiles
        
        barStr = fract2barstr(percentDone{file});
        timeStr = sec2timestr(timeLeft{file});
        funStr = title2funstr(barTitle{file});
        fullStr = [fullStr funStr ' ' barStr ' ' timeStr '\n'];
    end
    
    fprintf(repmat('\b', [1 nChars]));
    nChars = length(fullStr) - nFiles;
    fprintf(fullStr);
    drawnow('update');
    pause(1);
    
end


end

function [percentDone, timeLeft, barTitle] = progread(filePath)

fid = fopen(filePath);
data = fread(fid, 2, 'float32');
barTitle = char(fread(fid, inf, 'uchar').');
fclose(fid);

percentDone = data(1);
timeLeft = data(2);

end

function funstr = title2funstr(barTitle)

charLimit = 10;
strLength = length(barTitle);

if strLength > charLimit
    funstr = [barTitle(1:(charLimit-3)) '...'];
else
    funstr = [barTitle repmat(' ', [1 charLimit - strLength])];
end

end

function barstr = fract2barstr(percentDone)

numbars = floor(percentDone/100*20);

bars = repmat('|', 1, numbars);
spaces = repmat(' ', 1, 20 - numbars);

barstr = ['[' bars spaces ']'];
end

function timestr = sec2timestr(sec)

d = floor(sec/86400); % Days
sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

timestr = sprintf('%2dd %2dh %2dm %2ds ', d, h, m, s);
% timestr = sprintf('TR %02d:%02d:%02d:%02d ', d, h, m, s);
end
