function [bar, cleanup] = prog(varargin)
%PROGWRITE

if nargin == 1
    
    init = true;
    bar.title = varargin{1};
    
elseif nargin == 2
    
    init = false;
    bar = varargin{1};
    fractionDone = varargin{2};
end

if init
    
    bar.startTime = clock;
    progDir = [tempdir 'prog/'];
    bar.filePath = tempname(progDir);
    
    if ~exist(progDir, 'dir')
        mkdir(progDir);
    end
    
    cleanup = onCleanup(@()delete(bar.filePath));
    
else
    
    percentDone = floor(100*fractionDone);
    runTime = etime(clock, bar.startTime);
    timeLeft = runTime/fractionDone - runTime;
    
    progwrite(bar, percentDone, timeLeft);
end


end

function [] = progwrite(bar, percentDone, timeLeft)

fid = fopen(bar.filePath, 'w');
fwrite(fid, [percentDone timeLeft], 'float32');
fwrite(fid, bar.title, 'uchar');
fclose(fid);

end



