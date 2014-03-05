function [RfMatOut, startTime] = calc_multi_custombsc(Tx, Rx, Points, Filt, fs)
%CALC_SCAT_MULTI_CUSTOM 

import fieldii.calc_scat_multi

nPoints = size(Points, 1);

[RfMat, startTime] = calc_scat_multi(Tx, Rx, Points, ones(nPoints, 1));

RfCell = num2cell(RfMat, 1);

RfMatOut = cellfun(@(x) conv(x, Filt, 'same')./fs, RfCell, 'UniformOutput', false);
RfMatOut = cat(2, RfMatOut{:});

end

