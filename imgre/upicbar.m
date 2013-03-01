function [bar] = upicbar(varargin)

if nargin > 1
    init = true;
else
    init = false;
end

strlength = 40;

if ~init
    
    bar.title = varargin{1};
    bar.starttime = clock;
    disp([bar.title repmat(' ', 1, strlength)]);
    drawnow('update');
else
    
    bar = varargin{1};
    fractiondone = varargin{2};
    
    percentdone = floor(100*fractiondone);
    
    runtime = etime(clock, bar.starttime);
    timeleft = runtime/fractiondone - runtime;
    
    percentstr = sprintf('%3d%%%% ', percentdone);
    barstr = fract2barstr(fractiondone);
    timestr = sec2timestr(timeleft);
    msg = [percentstr timestr barstr];
    linemsg(msg, strlength); 
    
    if percentdone == 100
       fprintf('\b, done.\n');
       return
    end
end


end

function [] = linemsg(msg, nchars)

fprintf([repmat('\b', 1, nchars) msg]);
drawnow('update');
end

function barstr = fract2barstr(fractiondone)

numbars = floor(fractiondone*20);

bars = repmat('|', 1, numbars);
spaces = repmat(' ', 1, 20 - numbars);

barstr = ['[' bars spaces ']' ' '];
end

function timestr = sec2timestr(sec)

d = floor(sec/86400); % Days
sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

%timestr = sprintf('%2dd%2dh%2dm%2ds ', d, h, m, s);
timestr = sprintf('%02d:%02d:%02d:%02d ', d, h, m, s);
end
