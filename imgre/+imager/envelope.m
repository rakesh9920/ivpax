function [EnvMatOut] = envelope(BfMat, varargin)
% Envelope detection for RF data

if nargin > 1
    dim = varargin{1};
else
    dim = 1;
end

CellData = num2cell(double(BfMat), dim);
nLines = numel(CellData);
EnvMat = cell(size(CellData));

for line = 1:nLines
       
   EnvMat{line} = abs(hilbert(CellData{line}));
end

EnvMatOut = cell2mat(EnvMat);

end

