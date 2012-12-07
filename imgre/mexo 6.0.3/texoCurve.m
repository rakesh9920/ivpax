classdef texoCurve
   
    properties
        top = int32(0);
        mid = int32(0);
        btm = int32(0);
        vmid = int32(0);
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