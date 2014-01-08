function [I, Q] = iqdemod(Signal, fc, bw, fs)
%
%

import tools.lowpass

[nSample, nSig] = size(Signal);

t = ((0:(nSample-1))./fs).';
% I = zeros(nSample, nSig);
% Q = zeros(nSample, nSig);

hI = bsxfun(@times, Signal, 2.*cos(2*pi*fc.*t));
hQ = bsxfun(@times, -Signal, 2.*sin(2*pi*fc.*t));

I = lowpass(hI, 1, bw/2, fs);
Q = lowpass(hQ, 1, bw/2, fs);

% for s = 1:nSig
%     hI = Signal(:,s).*2.*cos(2*pi*fc.*t);
%     hQ = -Signal(:,s).*2.*sin(2*pi*fc.*t);
%     
% end

end

