classdef mexo < handle
    
    properties (SetAccess = private)
        obj_handle;
    end
    
    methods
        % constructor
        function obj = mexo()
           obj.obj_handle = texo_constructor();  
        end
        % destructor
        function delete(obj)
           texo_destructor(obj.obj_handle); 
        end 
        %methods
        function bool = init(obj, firmwarePath, pci, usm, hv, channels, tx, szCine)
            bool = texo_init(obj.obj_handle, firmwarePath, pci, usm, hv, ...
               channels, tx, szCine);
        end
        function bool = isInitialized(obj)
           bool = texo_isInitialized(obj.obj_handle); 
        end
        function bool = isImaging(obj)
            bool = texo_isImaging(obj.obj_handle);
        end
        function bool = activateProbeConnector(obj, probe)
            bool = texo_activateProbeConnector(obj.obj_handle, probe);
        end
        
    end  
end

