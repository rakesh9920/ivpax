function [] = progdisp()
%PROGDISP

import tools.querydir

if isunix
    tmp = '/home/bshieh/tmp/';
else
    tmp = tempdir;
end

progDir = [tmp 'prog/'];

[progFiles, nFiles] = querydir(progDir, '');

nChars = 0;
while true
    
    %     [percentDone, timeLeft, barTitle] = cellfun(@progread, progFiles, ...
    %         'UniformOutput', false);
    
    fullStr = '';
    nLines = 0;
    for file = 1:nFiles
        
        [percentDone, timeLeft, barTitle] = progread(progFiles{file});
        
        if isempty(percentDone)
            continue
        end
        
        nLines = nLines + 1;
        
        barStr = fract2barstr(percentDone);
        timeStr = sec2timestr(timeLeft);
        funStr = title2funstr(barTitle);
        fullStr = [fullStr barStr ' | ' timeStr  ' | ' funStr '\n'];
    end
    
    fprintf(repmat('\b', [1 nChars]));
    nChars = length(fullStr) - nLines;
    fprintf(fullStr);
    drawnow('update');
    pause(0.5);
    
end

end

function [percentDone, timeLeft, barTitle] = progread(filePath)

fid = fopen(filePath, 'r');

if fid == -1
    percentDone = [];
    timeLeft = [];
    barTitle = '';
    return
end

while true
    data = fread(fid, 2, 'float32');
    barTitle = char(fread(fid, inf, 'uchar').');
    
    if ~isempty(data)
        break
    end
    
    frewind(fid);
end

fclose(fid);

percentDone = data(1);
timeLeft = data(2);

end

function funstr = title2funstr(barTitle)

charLimit = 20;
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

% d = floor(sec/86400); % Days
% sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

timestr = sprintf('TR: %2dh/%2dm/%2ds ', h, m, s);
% timestr = sprintf('%2dd %2dh %2dm %2ds ', d, h, m, s);
% timestr = sprintf('TR %02d:%02d:%02d:%02d ', d, h, m, s);

end
