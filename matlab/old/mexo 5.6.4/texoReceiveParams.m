classdef texoReceiveParams < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    
    properties (Dependent)
        centerElement; %0
        aperture; %1
        angle; %2
        maxApertureDepth; %3
        acquisitionDepth; %4
        saveDelay; %5
        speedOfSound;  %6 
        channelMask; %7
        applyFocus; %8
        useManualDelays; %9
        manualDelays; %10
        customLineDuration; %11
        lgcValue; %12
        tgcSel; %13 
        tableIndex; %14
        decimation; %15
        numChannels; %16
    end
    
    methods
        % constructor
        function obj = texoReceiveParams()
            obj.obj_handle = texoReceiveParams_constructor();
        end
        % destructor
        function delete(obj)
            texoReceiveParams_destructor(obj.obj_handle);
        end
        % setters
        function set.centerElement(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 0, value);
        end
        function set.aperture(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 1, value);
        end
        function set.angle(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 2, value);
        end
        function set.maxApertureDepth(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 3, value);
        end
        function set.acquisitionDepth(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 4, value);
        end
        function set.saveDelay(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 5, value);
        end
        function set.speedOfSound(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 6, value);
        end
        function set.channelMask(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 7, value);
        end
        
        function set.applyFocus(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 8, value); 
        end
        function set.useManualDelays(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 9, value);
        end
        function set.manualDelays(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 10, value);
        end
        function set.customLineDuration(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 11, value);
        end
        function set.lgcValue(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 12, value);
        end
        function set.tgcSel(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 13, value);
        end
        function set.tableIndex(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 14, value);
        end
        function set.decimation(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 15, value);
        end
        function set.numChannels(obj, value)
           texoReceiveParams_setter(obj.obj_handle, 16, value);
        end
        % getters
        function value = get.centerElement(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 0);
        end
        function value = get.aperture(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 1);
        end
        function value = get.angle(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 2);
        end
        function value = get.maxApertureDepth(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 3);
        end
        function value = get.acquisitionDepth(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 4);
        end
        function value = get.saveDelay(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 5);
        end
        function value = get.speedOfSound(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 6);
        end
        function value = get.channelMask(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 7);
        end
        function value = get.applyFocus(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 8);
        end
        function value = get.useManualDelays(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 9);
        end
        function value = get.manualDelays(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 10);
        end
        function value = get.customLineDuration(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 11);
        end
        function value = get.lgcValue(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 12);
        end
        function value = get.tgcSel(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 13);
        end
        function value = get.tableIndex(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 14);
        end
        function value = get.decimation(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 15);
        end
        function value = get.numChannels(obj)
            value = texoReceiveParams_getter(obj.obj_handle, 16);
        end
    end
end

