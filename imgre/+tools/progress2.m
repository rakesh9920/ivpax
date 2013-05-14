function [progfig] =  progress2(fractiondone, position, title, numthreads)

% Author: Steve Hoelzer

% Set defaults for variables not passed in
if nargin < 1
    fractiondone = 0;
end
if nargin < 2
    position = 0;
end
if nargin < 3
    title = '';
end
if nargin < 4
    numthreads = 1;
end

try
    % Access progfig to see if it exists ('try' will fail if it doesn't)
    dummy = get(progfig,'UserData');
catch
    progfig = []; % Set to empty so a new progress bar is created
end

if fractiondone > 1
    fractiondone = 1;
end
percentdone = floor(100*fractiondone);

% Create new progress bar if needed

if (isempty(progfig))
    %firstIteration = 1;
    % Calculate position of progress bar in normalized units
    scrsz = [0 0 1 1];
    width = scrsz(3)*3/16;
    height = scrsz(4)/25*numthreads;
    if (length(position) == 1)
        hpad = scrsz(3)/64; % Padding from left or right edge of screen
        vpad = scrsz(4)/24; % Padding from top or bottom edge of screen
        left   = scrsz(3)/2 - width/2; % Default
        bottom = scrsz(4)/2 - height/2; % Default
        switch position
            case 0 % Center
                % Do nothing (default)
            case 1 % Top-right
                left   = scrsz(3) - width  - hpad;
                bottom = scrsz(4) - height - vpad;
            case 2 % Top-left
                left   = hpad;
                bottom = scrsz(4) - height - vpad;
            case 3 % Bottom-left
                left   = hpad;
                bottom = vpad;
            case 4 % Bottom-right
                left   = scrsz(3) - width  - hpad;
                bottom = vpad;
            case 5 % Random
                left   = rand * (scrsz(3)-width);
                bottom = rand * (scrsz(4)-height);
            otherwise
                warning('position must be (0-5). Reset to 0.')
        end
        position = [left bottom];
    elseif length(position) == 2
        % Error checking on position
        if (position(1) < 0) | (scrsz(3)-width < position(1))
            position(1) = max(min(position(1),scrsz(3)-width),0);
            warning('Horizontal position adjusted to fit on screen.')
        end
        if (position(2) < 0) | (scrsz(4)-height < position(2))
            position(2) = max(min(position(2),scrsz(4)-height),0);
            warning('Vertical position adjusted to fit on screen.')
        end
    else
        error('position is not formatted correctly')
    end
    
    % Initialize progress bar
    progfig = figure(...
        'Units',            'normalized',...
        'Position',         [position width height],...
        'NumberTitle',      'off',...
        'Resize',           'off',...
        'MenuBar',          'none',...
        'BackingStore',     'off' );
    
    for thread = 1:numthreads
       
        bottom = 1 - (1/numthreads)*thread + 0.02;
        height = 1/numthreads - 0.04;
        
        prog.progaxes{thread} = axes(...
            'Position',         [0.02 bottom 0.96 height], ...
            'XLim',             [0 1],...
            'YLim',             [0 1],...
            'Box',              'on',...
            'ytick',            [],...
            'xtick',            [] );
        prog.progpatch{thread} = patch(...
            'Parent',           prog.progaxes{thread},...
            'XData',            [0 0 0 0],...
            'YData',            [0 0 1 1],...
            'EraseMode',        'none' );
        set(prog.progpatch{thread},'FaceColor',[.1 1 .1]);
    end
%     progaxes = axes(...
%         'Position',         [0.02 0.15 0.96 0.70],...
%         'XLim',             [0 1],...
%         'YLim',             [0 1],...
%         'Box',              'on',...
%         'ytick',            [],...
%         'xtick',            [] );
%     prog.progpatch = patch(...
%         'XData',            [0 0 0 0],...
%         'YData',            [0 0 1 1],...
%         'EraseMode',        'none' );
    
    % enable this code if you want the bar to change colors when the
    % user clicks on the progress bar
    %     set(progfig,  'ButtonDownFcn',{@changecolor,progpatch});
    %     set(progaxes, 'ButtonDownFcn',{@changecolor,progpatch});
    %     set(progpatch,'ButtonDownFcn',{@changecolor,progpatch});
    %     changecolor(0,0,progpatch)
    
%     set(prog.progpatch,'FaceColor',[.1 1 .1]);
    
    % Set time of last update to ensure a redraw
    prog.lastupdate = clock - 1;
    
    % Task starting time reference
    prog.starttime = clock;
    
    set(progfig,'CloseRequestFcn',@closebar);
    set(progfig,'UserData',prog);
end

prog = get(progfig,'UserData');
progpatch = prog.progpatch;
lastupdate = prog.lastupdate;
starttime = prog.starttime;

%Enforce a minimum time interval between updates
%but allows for the case when the bar reaches 100% so that the user can see
%it
if (etime(clock,lastupdate) < 0.01 && ~(percentdone == 100))
    return
end

% Update progress patch
set(progpatch,'XData',[0 fractiondone fractiondone 0])

% Update progress figure title bar
if (fractiondone == 0)
    titlebarstr = ' 0%';
else
    runtime = etime(clock,starttime);
    timeleft = runtime/fractiondone - runtime;
    timeleftstr = sec2timestr(timeleft);
    titlebarstr = sprintf(' %2d%%    %s',percentdone,timeleftstr);
end
set(progfig,'Name',strcat(title,' - ',titlebarstr));

% Force redraw to show changes
drawnow


if percentdone == 100 % Task completed
    %change the close request function back to normal
    set(progfig,'CloseRequestFcn','closereq');
    delete(progfig) % Close progress bar
    
    return
end
% Record time of this update
prog.lastupdate = clock;

set(progfig,'UserData',prog);
end

%%
% ------------------------------------------------------------------------------
function changecolor(h,e,progpatch)
Change the color of the progress bar patch

colorlim = 2.8; % Must be <= 3.0 - This keeps the color from being too light
thiscolor = rand(1,3);
while sum(thiscolor) > colorlim
    thiscolor = rand(1,3);
end
set(progpatch,'FaceColor',thiscolor);
end


%%
% ------------------------------------------------------------------------------
function timestr = sec2timestr(sec)
% Convert a time measurement from seconds into a human readable string.

% Convert seconds to other units
d = floor(sec/86400); % Days
sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

% Create time string
if d > 0
    if d > 9
        timestr = sprintf('%d day',d);
    else
        timestr = sprintf('%d day, %d hr',d,h);
    end
elseif h > 0
    if h > 9
        timestr = sprintf('%d hr',h);
    else
        timestr = sprintf('%d hr, %d min',h,m);
    end
elseif m > 0
    if m > 9
        timestr = sprintf('%d min',m);
    else
        timestr = sprintf('%d min, %d sec',m,s);
    end
else
    timestr = sprintf('%d sec',s);
end
end

%%
function closebar(src,evnt)

delete(gcf)
end