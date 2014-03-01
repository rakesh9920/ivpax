function [u2] = lommel2(Y, Z, N)
%LOMMEL1

u2 = zeros(1, size(Z, 2));

for n = 1:N
   
    u2 = u2 + (-1)^n.*(Y./Z).^(2*n+2).*besselj(2*n+2, Z);
end

end

