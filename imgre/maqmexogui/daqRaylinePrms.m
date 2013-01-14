classdef daqRaylinePrms
    
    properties
        channels = uint32(zeros(1,4));
        gainDelay = int32(0);
        gainOffset = int32(0);
        lineDuration = int32(26);
        numSamples = int32(1024);
        rxDelay = int32(0);
        decimation = uint8(0);
        sampling = uint8(40);
    end
    
    methods
        function obj = set.channels(obj, value)
            if size(value,1) == 1 && size(value,2) == 4
                obj.channels = uint32(value);
            else
                error('channels must be a 1-by-4 int array');
            end
        end
        function obj = set.gainDelay(obj, value)
            obj.gainDelay = int32(value);
        end
        function obj = set.gainOffset(obj, value)
            obj.gainOffset = int32(value);
        end
        function obj = set.lineDuration(obj, value)
            obj.lineDuration = int32(value);
        end
        function obj = set.numSamples(obj, value)
            obj.numSamples = int32(value);
        end
        function obj = set.rxDelay(obj, value)
            obj.rxDelay = int32(value);
        end
        function obj = set.decimation(obj, value)
            obj.decimation = uint8(value); 
        end
        function obj = set.sampling(obj, value)
            obj.sampling = uint8(value);
        end
    end
end