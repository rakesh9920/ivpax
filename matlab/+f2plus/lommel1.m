function [u1] = lommel1(Y, Z, N)
%LOMMEL1

u1 = zeros(1, size(Z, 2));

for n = 1:N
   
    u1 = u1 + (-1)^n.*(Y./Z).^(2*n+1).*besselj(2*n+1, Z);
end

end

