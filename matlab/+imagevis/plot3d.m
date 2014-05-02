function [varargout] = plot3d(Data, varargin)

handles = plot3(Data(:,1), Data(:,2), Data(:,3), varargin{:});

if nargout == 1
    varargout{1} = handles;
end

end

