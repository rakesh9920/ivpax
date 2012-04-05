classdef texoo < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    
    methods
        % constructor
        function obj = texo()
           obj.obj_handle = texo_constructor();  
        end
        % destructor
        function delete(obj)
           texo_destructor(obj.obj_handle); 
        end 
        
        function bool = init(firmwarePath, pci, usm, hv, channels, tx, szCine)
            bool = texo_init(obj.obj_handle, firmwarePath, pci, usm, hv, ...
               channels, tx, szCine);
        end
    end  
end

