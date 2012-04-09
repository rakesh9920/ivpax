classdef texoTransmitParams < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    properties (Dependent)
        centerElement; %0
        aperture; %1
        focusDistance; %2
        angle; %3
        frequency; %4
        pulseShape; %5
        speedOfSound; %6
        useManualDelays; %7
        tableIndex; %8
        useDeadElements %9
        deadElements; %10
        trex; %11
    end
    
    methods
        % constructor
        function obj = texoTransmitParams()
            obj.obj_handle = texoTransmitParams_constructor();
        end
        % destructor
        function delete(obj)
            texoTransmitParams_destructor(obj.obj_handle);
        end
        % setters
        function set.centerElement(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 0, value);
        end
        function set.aperture(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 1, value);
        end
        function set.focusDistance(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 2, value);
        end
        function set.angle(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 3, value);
        end
        function set.frequency(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 4, value);
        end
        function set.pulseShape(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 5, value);
        end
        function set.speedOfSound(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 6, value);
        end
        function set.useManualDelays(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 7, value);
        end
        function set.tableIndex(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 8, value);
        end
        function set.useDeadElements(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 9, value);
        end
        function set.deadElements(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 10, value);
        end
        function set.trex(obj, value)
           texoTransmitParams_setter(obj.obj_handle, 11, value);
        end
        % getters
        function value = get.centerElement(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 0);
        end
        function value = get.aperture(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 1);
        end
        function value = get.focusDistance(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 2);
        end
        function value = get.angle(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 3);
        end
        function value = get.frequency(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 4);
        end
        function value = get.pulseShape(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 5);
        end
        function value = get.speedOfSound(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 6);
        end
        function value = get.useManualDelays(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 7);
        end
        function value = get.tableIndex(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 8);
        end
        function value = get.useDeadElements(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 9);
        end
        function value = get.deadElements(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 10);
        end
        function value = get.trex(obj)
            value = texoTransmitParams_getter(obj.obj_handle, 11);
        end
    end
end

