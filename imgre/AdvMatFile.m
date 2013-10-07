classdef AdvMatFile
    
    properties
        Label = {};
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
            
            ref = AdvDouble(subsref(obj.Mat.Data, s), obj.Mat.Label);
        end
        
        function obj = subsasgn(obj, s, b)
            
            switch s.type
                case '()'
                    
                    obj.Mat.Data(s.subs{:}) = double(b);
                case '.'
                    
                    switch lower(s.subs)
                        case 'data'
                            
                            obj.Mat.Data = double(b);
                            lbl = b.Label;
                            
                        case 'label'
                            
                            assert(isa(b, 'cell'));
                            lbl = b;
                            
                        otherwise
                            
                            obj.Mat.(s.subs) = b;
                            return
                    end
            end
            
            nd = ndims(obj.Mat.Data);
            
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