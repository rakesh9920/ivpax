classdef texoTransmitParams < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    properties
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
        
        function set.centerElement(obj, value)
           %texoTransmitParams_setter(obj.obj_handle, 0, value);
           obj.centerElement = value;
        end

    end
end

