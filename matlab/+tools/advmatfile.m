classdef advmatfile
    
    properties
        Mat;
    end
    
    methods
        % CONSTRUCTOR
        function obj = AdvMatFile(filename, varargin)
            obj.Mat = matfile(filename, varargin{:});
        end
        
        % OVERLOADED INDEXING METHODS
        function ref = subsref(obj, s)
            
            switch s(1).type
                case '.'
                    fieldname = s(1).subs; 
                    ref = obj.Mat.(strcat(upper(fieldname(1)), lower(fieldname(2:end))));
                case '()'
                    ref = AdvDouble(subsref(obj.Mat.Data, s), obj.Mat.Label);
            end
        end
        
        function obj = subsasgn(obj, s, b)
            
            switch s(1).type
                case '()'
                    obj.Mat.Data(s(1).subs{:}) = double(b);
                    lbl = b.Label;
                case '.'
                    switch lower(s(1).subs)
                        case 'data'
                            obj.Mat.Data = double(b);
                            lbl = b.Label;
                        case 'label'
                            assert(isa(b, 'cell'));
                            lbl = b;
                        otherwise
                            obj.Mat.(s(1).subs) = b;
                            return
                    end
            end
            
            nd = ndims(obj.Mat.Data);
            
            if ~isempty(lbl)
                if numel(lbl) < nd
                    
                    obj.Mat.Label = cell(1, nd);
                    obj.Mat.Label(1:numel(lbl)) = lbl;
                else
                    
                    obj.Mat.Label = lbl(1:nd);
                end
            end
            
        end
    end
end