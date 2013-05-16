function maqmexogui

fMain = figure( ...
    'Name', 'Maq/Mexo UI', ...
    'Visible', 'off', ...
    'Position', [0 0 400 100], ...
    'MenuBar', 'none', ...
    'NumberTitle', 'off');

hMexoMenu = uimenu('Label', 'Texo');
uimenu(hMexoMenu, ...
    'Label', 'Initialize', ...
    'Callback', {@MexoInitCallback});

hTriggers = uimenu(hMexoMenu, ...
    'Label', 'Triggers', ...
    'Separator', 'On');

hInput1 = uimenu(hTriggers, 'Label', 'Input1');
uimenu(hInput1, ...
    'Label', 'None', ...
    'Callback', {@MexoInput1NoneCallback});
uimenu(hInput1, ...
    'Label', 'Line', ...
    'Callback', {@MexoInput1LineCallback});
uimenu(hInput1, ...
    'Label', 'Frame', ...
    'Callback', {@MexoInput1FrameCallback});

hOutput1 = uimenu(hTriggers, 'Label', 'Output1');
uimenu(hOutput1, ...
    'Label', 'None', ...
    'Callback', {@MexoOutput1NoneCallback});
uimenu(hOutput1, ...
    'Label', 'Line', ...
    'Callback', {@MexoOutput1LineCallback});
uimenu(hOutput1, ...
    'Label', 'Frame', ...
    'Callback', {@MexoOutput1FrameCallback});
uimenu(hOutput1, ...
    'Label', 'Clock', ...
    'Callback', {@MexoOutput1ClockCallback});

hOutput2 = uimenu(hTriggers, 'Label', 'Output2');
uimenu(hOutput2, ...
    'Label', 'None', ...
    'Callback', {@MexoOutput2NoneCallback});
uimenu(hOutput2, ...
    'Label', 'Line', ...
    'Callback', {@MexoOutput2LineCallback});
uimenu(hOutput2, ...
    'Label', 'Frame', ...
    'Callback', {@MexoOutput2FrameCallback});
uimenu(hOutput2, ...
    'Label', 'Clock', ...
    'Callback', {@MexoOutput2ClockCallback});

uimenu(hMexoMenu, ...
    'Label','Parameters', ...
    'Callback', {@MexoSetParamsCallback});

hMaqMenu = uimenu('Label', 'DAQ');
uimenu(hMaqMenu,...
    'Label', 'Initialize', ...
    'Callback', {@MaqInitCallback});
uimenu(hMaqMenu, ...
    'Label', 'Run', ...
    'Callback', {@MaqRunCallback});
uimenu(hMaqMenu, ...
    'Label', 'Stop', ...
    'Enable', 'Off', ...
    'Callback', {@MaqStopCallback});
uimenu(hMaqMenu, ...
    'Label', 'Ext Trigger', ...
    'Separator', 'On', ...
    'Callback', {@MaqExtTriggerCallback});
uimenu(hMaqMenu, ...
    'Label','Ext Clock', ...
    'Callback', {@MaqExtClockCallback});
uimenu(hMaqMenu, ...
    'Label','Parameters', ...
    'Callback', {@MaqSetParamsCallback});

hStatusText = uicontrol(fMain, ...
    'Style', 'text', ...
    'String', 'Current status information', ...
    'HorizontalAlignment', 'left', ...
    'Position', [0 0 400 18]);

movegui(fMain, 'center');
set(fMain, 'Visible', 'on');

tx = texoTransmitParams();
rx = texoReceiveParams();
apr = texoCurve();

tx.centerElement = 64.5;
tx.aperture = 64; 
tx.angle = 0;
tx.focusDistance = 35000;
tx.frequency = 6600000;
tx.pulseShape = '+-';
tx.speedOfSound = 1540;
tx.tableIndex = -1;
tx.useManualDelays = false;
tx.manualDelays = zeros(1,129);
tx.useMask = false;
tx.mask = zeros(1,128);
tx.sync = 1;

rx.centerElement = 64.5;
rx.aperture = 64; 
rx.angle = 0; 
rx.maxApertureDepth = 50000; 
rx.acquisitionDepth = 50000;
rx.saveDelay = 0; 
rx.speedOfSound = 1540;  
rx.channelMask = [-1 -1];
rx.applyFocus = true; 
rx.useManualDelays = false; 
rx.manualDelays = zeros(1,65); 
rx.customLineDuration = 0; 
rx.lgcValue = 0; 
rx.tgcSel = 0; 
rx.tableIndex = -1; 
rx.decimation = 0; 
rx.numChannels = 64; 
rx.rxAprCrv = apr;
rx.weightType = 1;
rx.useCustomWindow = false;
rx.window = zeros(1,64);

seq = daqSequencePrms();
rl = daqRaylinePrms();

seq.freeRun = false;
seq.hpfBypass = false;
seq.divisor = 0;
seq.externalTrigger = true;
seq.externalClock = true;
seq.lnaGain = 1; 
seq.pgaGain = 1;
seq.biasCurrent = 1;
seq.fixedTGC = true;
seq.fixedTGCLevel = 40;

rl.channels = [-1 -1 -1 -1];
rl.gainDelay = 0;
rl.gainOffset = 0;
rl.lineDuration = 70;
rl.numSamples = 2678; 
rl.rxDelay = 0;
rl.decimation = 0;
rl.sampling = 40;

GetTexoParams()

    function [txprms rxprms] = GetTexoParams()
        
        txprms = struct2cell(struct(tx));
        rxprms = struct2cell(struct(rx));
        
        cm = rxprms{8};
        crv = rxprms{18};

        insert(rxprms, crv.vmid, 19);
        insert(rxprms, crv.btm, 19);
        insert(rxprms, crv.mid, 19);
        insert(rxprms, crv.top, 19);
        insert(rxprms, cm(2), 9);
        insert(rxprms, cm(1), 9);
        
        txprms([9 12]) = [];
        rxprms([8 13 20 27]) = [];
        
        txprms
        rxprms
    end

    function SetTexoParams(prms)
        
    end


    function prms = GetDaqParams()
        
        prms = [struct2cell(struct(seq)); struct2cell(struct(rl))];
        prms([4 5 11]) = [];
    end

    function SetDaqParams(prms)
        
        seq.freeRun = prms{1};
        seq.hpfBypass = prms{2};
        seq.divisor = prms{3};
        seq.lnaGain = prms{4};
        seq.pgaGain = prms{5};
        seq.fixedTGC = prms{6};
        seq.fixedTGCLevel = prms{7};

        rl.gainDelay = prms{8};
        rl.gainOffset = prms{9};
        rl.lineDuration = prms{10};
        rl.numSamples = prms{1};
        rl.rxDelay = prms{12};
        rl.decimation = prms{13};
        rl.sampling = prms{14};
    end

    function MexoSetParamsCallback(hObject, eventdata)
        
        fMexoParams = figure( ...
            'Name', 'Mexo Parameters', ...
            'Visible', 'off', ...
            'Position', [0 0 400 400], ...
            'MenuBar', 'none', ...
            'NumberTitle', 'off');
        
        movegui(fMexoParams, 'center');
        set(fMexoParams, 'Visible', 'On');
    end

    function MaqSetParamsCallback(hObject, eventdata)
        
        fMaqParams = figure( ...
            'Name', 'Maq Parameters', ...
            'Visible', 'off', ...
            'Position', [0 0 220 400], ...
            'MenuBar', 'none', ...
            'NumberTitle', 'off');
        cnames = {'value'};
        rnames = {'freeRun', 'hpfBypass', 'divisor', 'lnaGain', 'pgaGain',...
            'biasCurrent', 'fixedTGC', 'fixedTGCLevel', 'gainDelay', ...
            'gainOffset', 'lineDuration', 'numSamples', 'rxDelay', ...
            'decimation', 'sampling'};
        
        prms = GetDaqParams();
        
        uitable(fMaqParams, ...
            'RowName', rnames, ...
            'CellEditCallback', @MaqEditCallback, ...
            'ColumnName', cnames, ...
            'ColumnEditable', true, ...
            'ColumnWidth', {'auto'}, ...
            'Data', prms, ...
            'Position', [1 1 220 400]);
        
        movegui(fMaqParams, 'center');
        set(fMaqParams, 'Visible', 'On');
        
        function MaqEditCallback(hObject, eventdata)   
            
            prms{eventdata.Indices(1)} = eventdata.NewData';
            SetDaqParams(prms);
        end
    end
end

function newvec = insert(oldvec, value, ind)
    
    newvec = [oldvec(1:ind-1) value oldvec(ind:end)];
    
end