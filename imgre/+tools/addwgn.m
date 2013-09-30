function [RfDataOut] = addwgn(dim, RfData, dbLevel)
%
%

CellData = num2cell(RfData, dim);
nInd = numel(CellData);

for ind = 1:nInd
    
    signal = CellData{ind};
    power = 20.*log10(rms(signal));
    
    signalDim = cell(1,2);
    [signalDim{:}] = size(signal);
    
    noise = wgn(signalDim{:}, power - dbLevel);
    
    CellData{ind} = signal + noise; 
end

RfDataOut = cell2mat(CellData);


end