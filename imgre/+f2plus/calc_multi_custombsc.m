function [RfMatOut, startTime] = calc_multi_custombsc(Tx, Rx, Points, Filt, fs)
%CALC_SCAT_MULTI_CUSTOM 

import fieldii.calc_scat_multi

nPoints = size(Points, 1);

[RfMat, startTime] = calc_scat_multi(Tx, Rx, Points, ones(nPoints, 1));

Filt = shiftdata(Filt, []);

RfMatOut = zeros(size(RfMat));

for sig = 1:size(RfMat, 2);
    RfMatOut(:,sig) = conv(RfMat(:,sig), Filt, 'same')./fs;
end

% RfCell = num2cell(RfMat, 1);
% RfMatOut = cellfun(@(x) conv(x, Filt, 'same')./fs, RfCell, 'UniformOutput', false);
% RfMatOut = cat(2, RfMatOut{:});

end

