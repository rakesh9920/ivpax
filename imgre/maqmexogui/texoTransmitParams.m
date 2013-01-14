classdef texoTransmitParams

    properties
        centerElement; 
        aperture; 
        focusDistance; 
        angle; 
        frequency; 
        pulseShape; 
        speedOfSound; 
        useManualDelays; 
        manualDelays 
        tableIndex; 
        useMask;
        mask;
        sync;
    end
    
    methods
        % setters
        function obj = set.centerElement(obj, value)
            obj.centerElement = double(value);
        end
        function obj = set.aperture(obj, value)
            obj.aperture = int32(value);
        end
        function obj = set.focusDistance(obj, value)
            obj.focusDistance = int32(value);
        end
        function obj = set.angle(obj, value)
            obj.angle = int32(value);
        end
        function obj = set.frequency(obj, value)
            obj.frequency = int32(value);
        end
        function obj = set.pulseShape(obj, value)
            if size(value,1) == 1 && size(value,2) <= 96 
                obj.pulseShape = char(value);
            else
                error('pulseShape must be char array of max dimension 96');
            end
        end
        function obj = set.speedOfSound(obj, value)
            obj.speedOfSound = int32(value);
        end
        function obj = set.useManualDelays(obj, value)
            obj.useManualDelays = int32(value);
        end
        function obj = set.manualDelays(obj, value)
            if size(value,1) == 1 && size(value,2) == 129
               obj.manualDelays = int32(value); 
            else
                error('mask must be a 1-by-129 int array');
            end
        end
        function obj = set.tableIndex(obj, value)
            obj.tableIndex = int32(value);
        end

        function obj = set.useMask(obj, value)
            obj.useMask = int32(value);         
        end
        function obj = set.mask(obj, value)
            if size(value,1) == 1 && size(value,2) == 128
               obj.mask = int32(value); 
            else
                error('mask must be a 1-by-128 int array');
            end
        end
        function obj = set.sync(obj, value)
            obj.sync = int32(value);
        end
    end
end

