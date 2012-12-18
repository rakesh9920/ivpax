classdef daqSequencePrms
    
    properties
        freeRun = int32(0)
        divisor = uint8(0);
        hpfBypass = int32(0);
        externalTrigger = int32(0);
        externalClock = int32(0);
        fixedTGC = int32(0);
        fixedTGCLevel = int32(0);
        lnaGain = int32(0);
        pgaGain = int32(0);
        biasCurrent = int32(0);
    end
    
    methods
        % setters
        function obj = set.freeRun(obj, value)
            obj.freeRun = int32(value);
        end
        function obj = set.divisor(obj, value)
            obj.divisor = uint8(value);
        end
        function obj = set.hpfBypass(obj, value)
            obj.hpfBypass = int32(value);
        end
        function obj = set.externalTrigger(obj, value)
            obj.externalTrigger = int32(value);
        end
        function obj = set.externalClock(obj, value)
            obj.externalClock = int32(value);
        end
        function obj = set.fixedTGC(obj, value)
            obj.fixedTGC = int32(value);
        end
        function obj = set.fixedTGCLevel(obj, value)
            obj.fixedTGCLevel = int32(value);
        end
        function obj = set.lnaGain(obj, value)
            obj.lnaGain = int32(value);
        end
        function obj = set.pgaGain(obj, value)
            obj.pgaGain = int32(value);
        end
        function obj = set.biasCurrent(obj, value)
            obj.biasCurrent = int32(value);
        end 
    end 
end