classdef AdvMatFile
    
    properties
        Label = {};
        Dim = 0;
        Mat;
    end
    
    methods
        
        function obj = AdvMatFile(filename, varargin)
            obj.Mat = matfile(filename, varargin{:});
            
            if exist(filename,'file') == 2
                obj.Label = obj.Mat.Label;
                obj.Dim = obj.Mat.Dim;
            end
        end
        
        function ref = subsref(obj, s)
            
            ref = AdvDouble(subsref(obj.Mat.Data, s), obj.Label);
        end
        
        function obj = subsasgn(obj, s, b)
            
            obj.Mat.Data(s.subs{:}) = b;
            obj.Dim = ndims(obj.Mat.Data);
  
            lbl = obj.Label;
            if numel(lbl) < obj.
                
                obj.Label = cell(1, nd);
                obj.Label(1:numel(lbl)) = lbl;
            else
                
                obj.Label = lbl(1:nd);
            end
            
        end
        
        function obj = set.Label(obj, lbl)
            
            nd = obj.Dim;
            
            
        end
    end
    
end