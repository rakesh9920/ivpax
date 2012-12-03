classdef texoLineInfo
    
    properties
        lineSize;
        lineDuration;
    end
    
    methods
        % setters
        function obj = set.lineSize(obj, value)
            obj.lineSize = int32(value);
        end
        function obj = set.lineDuration(obj, value)
            obj.lineDuration = int32(value);
        end
    end
end