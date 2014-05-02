function gui
%

% main figure layout
f_main = figure('Visible','off','Position',[0,0,500,500],'MenuBar','none');
h_axes = axes('Units','Pixels','Position',[50, 50, 400, 400]);
h_loadmenu = uimenu('Label','Load','Callback',{@load_callback});
h_optmenu = uimenu('Label','Options');
uimenu(h_optmenu,'Label','Filtering','Callback',{@filtering_callback});
uimenu(h_optmenu,'Label','Averaging','Callback',{@averaging_callback});
movegui(f_main,'center');
set(f_main,'Visible','on');

% vars

% bool
dataLoaded = false;
filterOn = false;

% subfunctions
    function loadData()
       hdfilename = getappdata(f_main,'hdfilename');
       rffilename = getappdata(f_main,'rffilename');
       header = readHeader(hdfilename);
       rfcube = readRF(rffilename,header);
       setappdata(f_main,'rfcube',rfcube);
       setappdata(f_main,'header',header);
       dataLoaded = true;
       processData();
    end

    function processData()
       rfcube = getappdata(f_main,'rfcube');
       header = getappdata(f_main,'header');
       if filterOn
           fc = str2double(getappdata(f_main,'fc'));
           f1 = str2double(getappdata(f_main,'f1'));
           f2 = str2double(getappdata(f_main,'f2'));
           fs = str2double(getappdata(f_main,'fs'));
           rfcube = bandpass(rfcube,f1,f2,fs);
       end
       img = procBMode(rfcube,header,false);
       imager(img,f_main);
    end

% callbacks
    function load_callback(source,eventdata)    

        % load figure layout
        f_load = figure('Visible','off','Position',[0,0,306,83],'MenuBar','none');
        h_rftext = uicontrol('Style','edit','Position',[2,56,200,25],...
            'String',getappdata(f_main,'rffilename'));
        h_hdtext = uicontrol('Style','edit','Position',[2,29,200,25],...
            'String',getappdata(f_main,'hdfilename'));
        h_rfbutton = uicontrol('Style','pushbutton','String','Browse',...
        'Position',[204,56,100,25],'Callback',{@rfbutton_callback});
        h_hdbutton = uicontrol('Style','pushbutton','String','Browse',...
        'Position',[204,29,100,25],'Callback',{@hdbutton_callback});
        h_okbutton = uicontrol('Style','pushbutton','String','ok',...
        'Position',[102,2,100,25],'Callback',{@okbutton_callback});
        h_cancelbutton = uicontrol('Style','pushbutton','String','cancel',...
        'Position',[204,2,100,25],'Callback',{@cancelbutton_callback});
        movegui(f_load,'center');
        set(f_load,'Visible','on');
        
        function rfbutton_callback(source,eventdata)
            
            [filename pathname] = uigetfile('*.rf');
            set(h_rftext,'String',strcat(pathname,filename));    
        end
        
        function hdbutton_callback(source,eventdata)
            
            [filename pathname] = uigetfile('*.hd');
            set(h_hdtext,'String',strcat(pathname,filename)); 
        end
        
        function cancelbutton_callback(source,eventdata)
            close(f_load);
        end
        
        function okbutton_callback(source,eventdata)
            rffilename = get(h_rftext,'String');
            hdfilename = get(h_hdtext,'String');
            
            if isa(rffilename,'char') && isa(hdfilename,'char')
                setappdata(f_main,'rffilename',rffilename);
                setappdata(f_main,'hdfilename',hdfilename);
                close(f_load);
                loadData();
            else
                error('must select rf and hd files to load');
            end
        end
    end

    function filtering_callback(source,eventdata)
        
        f_filter = figure('Visible','off','Position',[0,0,186,137],'MenuBar','none');
        uicontrol('Style','text','Position',[2,106,100,25],'String','center freq [Mhz]','BackgroundColor',[0.79 0.79 0.79]);
        uicontrol('Style','text','Position',[2,79,100,25],'String','low freq [Mhz]','BackgroundColor',[0.79 0.79 0.79]);
        uicontrol('Style','text','Position',[2,52,100,25],'String','high freq [Mhz]','BackgroundColor',[0.79 0.79 0.79]);
        uicontrol('Style','text','Position',[2,25,100,25],'String','sampling freq [Mhz]','BackgroundColor',[0.79 0.79 0.79]);
        h_fctext = uicontrol('Style','edit','Position',[104,110,80,25],...
            'String',getappdata(f_main,'fc'));
        h_f1text = uicontrol('Style','edit','Position',[104,83,80,25],...
            'String',getappdata(f_main,'f1'));
        h_f2text = uicontrol('Style','edit','Position',[104,56,80,25],...
            'String',getappdata(f_main,'f2'));
        h_fstext = uicontrol('Style','edit','Position',[104,29,80,25],...
            'String',getappdata(f_main,'fs'));
        h_okbutton = uicontrol('Style','pushbutton','Position',[12,2,80,25],...
            'Callback',{@okbutton_callback},'String','Ok');
        h_cancelbutton = uicontrol('Style','pushbutton','Position',[94,2,80,25],...
            'Callback',{@cancelbutton_callback},'String','Cancel');
        movegui(f_filter,'center');
        set(f_filter,'Visible','on');
        
        function okbutton_callback(source,eventdata)
            fc = get(h_fctext,'String');
            f1 = get(h_f1text,'String');
            f2 = get(h_f2text,'String');
            fs = get(h_fstext,'String');
            
            if isa(fc,'char') && isa(f1,'char') && isa(f2,'char') && isa(fs,'char')
                setappdata(f_main,'fc',fc);
                setappdata(f_main,'f1',f1);
                setappdata(f_main,'f2',f2);
                setappdata(f_main,'fs',fs);
                filterOn = true;
                close(f_filter);
                if dataLoaded
                    processData();
                end
            else
                error('invalid filter values');
            end
        end
        
        function cancelbutton_callback(source,eventdata)
            close(f_filter);
        end
        
        
    end

end

