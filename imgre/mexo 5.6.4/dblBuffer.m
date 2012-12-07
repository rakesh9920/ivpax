classdef dblBuffer < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    
    methods
        % constructor
        function obj = dblBuffer()
            obj.obj_handle = dblBuffer_constructor();
        end
        % destructor
        function delete(obj)
            dblBuffer_destructor(obj.obj_handle);
        end
        % methods
        function transferFromCine(obj, tex, numSamples)
            dblBuffer_transferData(obj.obj_handle, tex.obj_handle, numSamples*2);
        end
        function data = getBuffer(obj, numSamples)
            data = dblBuffer_getBuffer(obj.obj_handle, numSamples);
        end
    end
end
