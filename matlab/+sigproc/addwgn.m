function [RfDataOut] = addwgn(dim, RfData, dbLevel)
%ADDWGN Adds white gaussian noise to data at the specified power level (in
%decibels).

CellData = num2cell(RfData, dim);
nLines = numel(CellData);

for ind = 1:nLines
    
    signal = CellData{ind};
    power = 20.*log10(rms(signal));
    
    signalDim = cell(1,2);
    [signalDim{:}] = size(signal);
    
    noise = wgn(signalDim{:}, power - dbLevel);
    
    CellData{ind} = signal + noise; 
end

RfDataOut = cell2mat(CellData);


end