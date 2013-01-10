classdef texoReceiveParams
     
    properties
        centerElement; 
        aperture; 
        angle; 
        maxApertureDepth; 
        acquisitionDepth; 
        saveDelay; 
        speedOfSound;  
        channelMask; 
        applyFocus; 
        useManualDelays; 
        manualDelays; 
        customLineDuration; 
        lgcValue; 
        tgcSel; 
        tableIndex; 
        decimation; 
        numChannels; 
        rxAprCrv;
        weightType;
        useCustomWindow;
        window;
    end
    
    methods
        % setters
        function obj = set.centerElement(obj, value)
            obj.centerElement = double(value);
        end
        function obj = set.aperture(obj, value)
            obj.aperture = int32(value);
        end
        function obj = set.angle(obj, value)
            obj.angle = int32(value);
        end
        function obj = set.maxApertureDepth(obj, value)
            obj.maxApertureDepth = int32(value);
        end
        function obj = set.acquisitionDepth(obj, value)
            obj.acquisitionDepth = int32(value);
        end
        function obj = set.saveDelay(obj, value)
            obj.saveDelay = int32(value);
        end
        function obj = set.speedOfSound(obj, value)
            obj.speedOfSound = int32(value);
        end
        function obj = set.channelMask(obj, value)
            if size(value,1) == 1 && size(value,2) == 2
                obj.channelMask = int32(value);
            else
                error('channelMask must be a 1-by-2 int array');
            end
        end
        function obj = set.applyFocus(obj, value)
            obj.applyFocus = int32(value);
        end
        function obj = set.useManualDelays(obj, value)
            obj.useManualDelays = int32(value);
        end
        function obj = set.manualDelays(obj, value)
            if size(value,1) == 1 && size(value,2) == 65
                obj.manualDelays = int32(value);
            else
                error('manualDelays must be a 1-by-65 int array');
            end
        end
        function obj = set.customLineDuration(obj, value)
            obj.customLineDuration = int32(value);
        end
        function obj = set.lgcValue(obj, value)
            obj.lgcValue = int32(value);
        end
        function obj = set.tgcSel(obj, value)
            obj.tgcSel = int32(value);  
        end
        function obj = set.tableIndex(obj, value)
            obj.tableIndex = int32(value);
        end
        function obj = set.decimation(obj, value)
            obj.decimation = int32(value);
        end
        function obj = set.numChannels(obj, value)
            obj.numChannels = int32(value);
        end
        function obj = set.rxAprCrv(obj, value)
            if isa(value, 'texoCurve')
                obj.rxAprCrv = value;
            else
                error('rxAprCrv must be a texoCurve object');
            end
        end
        function obj = set.weightType(obj, value)
            obj.weightType = int32(value);
        end
        function obj = set.useCustomWindow(obj, value)
            obj.useCustomWindow = int32(value);
        end
        function obj = set.window(obj, value)
            if size(value,1) == 1 && size(value,2) == 64
                obj.window = char(value);
            else
                error('window must be a 1-by-64 char array');
            end
        end
    end
end

