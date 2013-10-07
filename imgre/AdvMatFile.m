classdef AdvMatFile
    
    properties
        Label = {};
        %Dim = 0;
        Mat;
    end
    
    methods
        
        function obj = AdvMatFile(filename, varargin)
            obj.Mat = matfile(filename, varargin{:});
            
            if exist(filename,'file') == 2
                
                obj.Label = obj.Mat.Label;
            end
        end
        
        function ref = subsref(obj, s)
            
            ref = AdvDouble(subsref(obj.Mat.Data, s), obj.Label);
        end
        
        function obj = subsasgn(obj, s, b)
            
            switch s.type
                
                case '()'
                    
                    obj.Mat.Data(s.subs{:}) = b;
                    
                case '.'
                    
                    if strcmpi(s.subs, 'data')
                        
                        obj.Mat.Data = b;
                    else
                        
                        obj.Mat.(s.subs) = b;
                        return
                    end
            end
            
            nd = ndims(obj.Mat.Data);
            
            lbl = b.Label;
            if ~isempty(lbl)
                if numel(lbl) < nd
                    
                    obj.Label = cell(1, nd);
                    obj.Label(1:numel(lbl)) = lbl;
                else
                    
                    obj.Label = lbl(1:nd);
                end
            end
        end
    end
    
end