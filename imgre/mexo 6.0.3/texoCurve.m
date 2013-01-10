classdef texoCurve
   
    properties
        top = int32(100);
        mid = int32(100);
        btm = int32(100);
        vmid = int32(50);
    end
    
    methods
        % setters
        function obj = set.top(obj, value)
            obj.top = int32(value);
        end
        function obj = set.mid(obj, value)
            obj.mid = int32(value);
        end
        function obj = set.btm(obj, value)
            obj.btm = int32(value);
        end
        function obj = set.vmid(obj, value)
            obj.vmid = int32(value);
        end
    end
end