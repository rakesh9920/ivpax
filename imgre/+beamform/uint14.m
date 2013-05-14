function [truncated] = uint14(input)

error(nargchk(1, 1, nargin, 'struct'));

[n m] = size(input);

truncated = uint16(input);

for row = 1:n
    for col = 1:m
        number = input(row,col);
        if number > 16383
            truncated(row,col) = 16383;
        elseif number < 0
            truncated(row,col) = 0;
        end
    end
end

end

