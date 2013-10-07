classdef AdvDouble < double
    
    properties
        Label = {};
        Dim = 0;
    end
    
    methods
        % CONSTRUCTORS
        function obj = AdvDouble(data, lbl)
            
            assert(isa(lbl, 'cell'));
            
            if nargin == 0
                data = 0;
                lbl = {};
            end
            
            obj = obj@double(data);
            
            nd = ndims(data);
            obj.Dim = nd;
            obj.Label = lbl;
        end
        
        % OVERLOADED INDEXING METHODS
        function ref = subsref(obj, s)
            
            data = double(obj);
            
            subs = s.subs;
            
            
            ref = subsref(data, s);
        end
        
        function obj = subsasgn(obj, s, b)
            
            data = double(obj);
            obj = AdvDouble(subsasgn(data, s, b), obj.Label);
        end
        
        % OVERLOADED CONCATENATION METHODS
        function newobj = horzcat(varargin)
            
            newobj = cat(2, varargin{:});
        end
        
        function newobj = vertcat(varargin)
            
            newobj = cat(1, varargin{:});
        end
        
        function newobj = cat(dim, varargin)
            
            lbl = varargin{1}.Label;
            
            data = cell(1, nargin - 1);
            for in = 1:(nargin - 1)
                data{in} = double(varargin{in});
            end
            
            newdouble = cat(dim, data{:});
            
            newobj = AdvDouble(newdouble, lbl);
            
        end
        
        % OVERLOADED DATA ORGANIZATION METHODS
        function obj = transpose(obj)
            
            data = double(obj);
            obj = AdvDouble(transpose(data), fliplr(obj.Label));
        end
        
        function obj = ctranspose(obj)
            
            data = double(obj);
            obj = AdvDouble(ctranspose(data), fliplr(obj.Label));
        end
        
        function obj = squeeze(obj)
            
            data = double(obj);
            dim = size(data);
            
            obj.Label(dim == 1) = [];
            
            obj = AdvDouble(squeeze(data), obj.Label);
        end
        
        function obj = permute(obj, order)
            
            data = double(obj);
            lbl = obj.Label;
            
            newlbl = cell(1, length(order));
            
            for idx = 1:length(order)
                
                if order(idx) > ndims(data)
                    newlbl{idx} = [];
                else
                    newlbl{idx} = lbl{order(idx)};
                end
            end
            
            obj = AdvDouble(permute(data, order), newlbl);
        end
        
        % GETTERS AND SETTERS
        function obj = set.Label(obj, lbl)
            
            nd = ndims(double(obj));
            if numel(lbl) < nd
                obj.Label = cell(1, nd);
                obj.Label(1:numel(lbl)) = lbl;
            else
                obj.Label = lbl(1:nd);
            end
        end
        
        function lbl = get.Label(obj)
            lbl = obj.Label;
        end
        
    end
end

