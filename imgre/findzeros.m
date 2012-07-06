function [roots] = findzeros(sig, dim)

if dim == 2
    sig = sig.';
end
[nrows ncols] = size(sig);
roots = zeros(nrows,ncols);

for row = 1:nrows
    numroot = 0;
    for sample = 1:(ncols - 1)
        
        if sig(row,sample)*sig(row,sample+1) < 0
            roots(row, numroot + 1) = sample+1;
            numroot = numroot + 1;
        end
    end
    
end

roots((numroot+1):end) = [];

end