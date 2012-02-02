function [sigOut] = arrayshift(sigIn, shift)
%
%

% input arguments error checking
error(nargchk(2, 2, nargin, 'struct'));

sigLength = length(sigIn);

if abs(shift) > sigLength
    sigOut = zeros(1,sigLength);
elseif shift > 0 % shift right if positive (delay in time)
    sigOut = [zeros(1,shift) sigIn(1:sigLength-shift)];
elseif shift < 0 % shift left if negative (forward in time)
    sigOut = [sigIn(1-shift:sigLength) zeros(1,-shift)];
else
    sigOut = sigIn;
end

end

