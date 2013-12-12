classdef advdouble < double
    
    
    properties
        Label = {};
        Dim = 0;
        Meta;
    end
    
    methods
        % CONSTRUCTOR
        function obj = advdouble(varargin)
            
            switch nargin
                case 3
                    meta = varargin{3};
                    lbl = varargin{2};
                    data = varargin{1};
                case 2
                    meta = [];
                    lbl = varargin{2};
                    data = varargin{1};
                case 1
                    meta = [];
                    lbl = {};
                    data = varargin{1};
                otherwise
                    if nargin > 3
                        error('too many input arguments');
                    else
                        meta = [];
                        lbl = {};
                        data = [];
                    end
            end
            
            obj = obj@double(data);
            nd = ndims(data);
            obj.Dim = nd;
            obj.Label = lbl;
            obj.Meta = meta;
        end
        
        % OVERLOADED INDEXING METHODS
        function ref = subsref(obj, s)
            
            switch s(1).type
                case '.'
                    sub1 = lower(s(1).subs);
                    sub1(1) = upper(sub1(1));
                    
                    if size(s, 2) > 1
                        ref = subsref(obj.(sub1), s(2:end));
                    else
                        ref = obj.(sub1);
                    end
                case '{}'
                case '()'
                    data = double(obj);
                    
                    % check for label reference in subs
                    islabel = cellfun(@(x) isa(x, 'char') && ~strcmpi(x, ':'), s.subs);
                    
                    if any(islabel)
                        
                        newsubs = repmat({':'}, 1, ndims(data));
                        
                        loc = find(islabel);
                        for idx = 1:numel(loc)
                            
                            dim = find(strcmpi(s.subs{loc(idx)}, obj.Label));
                            if dim > 0
                                
                                newsubs{dim} = s.subs{loc(idx)+1};
                            end
                        end
                        
                        s.subs = newsubs;
                    end
                    
                    ref = tools.advdouble(subsref(data, s), obj.Label, obj.Meta);
            end
        end
        
        function obj = subsasgn(obj, s, b)
            
            switch s(1).type
                case '.'
                    sub1 = lower(s(1).subs);
                    sub1(1) = upper(sub1(1));
                    
                    if size(s, 2) > 1
                        obj.(sub1) = subsasgn(obj.(sub1), s(2:end), b);
                    else
                        obj.(sub1) = b;
                    end
                case '{}'
                case '()'
                    data = double(obj);
                    
                    % check for label reference in subs
                    islabel = cellfun(@(x) isa(x, 'char') && ~strcmpi(x, ':'), s.subs);
                    
                    if any(islabel)
                        
                        newsubs = repmat({':'}, 1, ndims(data));
                        
                        loc = find(islabel);
                        for idx = 1:numel(loc)
                            
                            dim = find(strcmpi(s.subs{loc(idx)}, obj.Label));
                            if dim > 0
                                
                                newsubs{dim} = s.subs{loc(idx)+1};
                            end
                        end
                        
                        s.subs = newsubs;
                    end
                    
                    obj = tools.advdouble(subsasgn(data, s, b), obj.Label, obj.Meta);
            end
        end
        
        function varargout = size(obj, varargin)
            
            data = double(obj);
            lbl = obj.Label;
            if nargout > 1
                outargs = cell(nargout);
            else
                outargs = cell(1);
            end
            
            if nargin > 1
                
                dimlabel = varargin{1};
                if isa(dimlabel, 'char')
                    loc = find(strcmpi(dimlabel, lbl));
                    if isempty(loc)
                        error('invalid dimension label');
                    end
                else
                    loc = dimlabel;
                end
                
                [outargs{:}] = size(data, loc);
            else
                [outargs{:}] = size(data);
            end
            
            varargout = outargs;
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
            meta = varargin{1}.Meta;
            
            data = cell(1, nargin - 1);
            for in = 1:(nargin - 1)
                data{in} = double(varargin{in});
            end
            
            newdouble = cat(dim, data{:});
            
            newobj = tools.advdouble(newdouble, lbl, meta);
        end
        
        % OVERLOADED DATA ORGANIZATION METHODS
        function obj = transpose(obj)
            
            data = double(obj);
            obj = tools.advdouble(transpose(data), fliplr(obj.Label), obj.Meta);
        end
        
        function obj = ctranspose(obj)
            
            data = double(obj);
            obj = tools.advdouble(ctranspose(data), fliplr(obj.Label), obj.Meta);
        end
        
        function obj = squeeze(obj)
            
            data = double(obj);
            dim = size(data);
            
            obj.Label(dim == 1) = [];
            
            obj = tools.advdouble(squeeze(data), obj.Label, obj.Meta);
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
            
            obj = tools.advdouble(permute(data, order), newlbl, obj.Meta);
        end
        
        % OVERLOAD OPERATORS
        function obj = plus(a, b)
            
            data = double(a) + double(b);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = minus(a, b)
            
            data = double(a) - double(b);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = uplus(a)
            
            data = -double(a);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = uminus(a)
            
            data = -double(a);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = times(a, b)
            
            data = double(a).*double(b);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = mtimes(a, b)
            
            data = double(a)*double(b);
            lbla = a.Label;
            lblb = b.Label;
            lbl = cat(2, lbla(1), lblb(2));
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        function obj = power(a, b)
            
            data = double(a).^double(b);
            lbl = a.Label;
            obj = tools.advdouble(data, lbl, a.Meta);
        end
        
        % OVERLOAD OTHER METHODS
        function obj = padarray(varargin)
            
            adv = varargin{1};

            remarg = varargin(2:end);
            newdata = padarray(double(adv), remarg{:});
            obj = tools.advdouble(newdata, adv.Label, adv.Meta);
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
    end
end

