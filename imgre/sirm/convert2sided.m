function [Signal2] = convert2sided(Signal1, dim)

dim = floor(dim);
assert(dim > 0, 'Invalid dimension argument');

nSample = size(Signal1, dim);

isEven = mod(nSample, 2) == 0;

if isEven
    
    Index1(1:ndims(Signal1)) = {':'};
    Index2 = Index1;
    
    Index1{dim} = 1:nSample;
    Index2{dim} = nSample:-1:2;
    
    Signal2 = cat(dim, Signal1(Index1{:}), conj(Signal1(Index2{:})))./2;
else
    
    Index1(1:ndims(Signal1)) = {':'};
    Index2 = Index1;
    Index3 = Index1;
    
    Index1{dim} = 1:(nSample - 1);
    Index2{dim} = nSample;
    Index3{dim} = (nSample - 1):-1:2;
    
    Signal2 = cat(dim, Signal1(Index1{:}), conj(Signal1(Index2{:})), ...
        conj(Signal1(Index3{:})))./2;
end

% if nRow == 1
%
%     isEven = mod(nCol, 2) == 0;
%
%     if isEven
%
%         Signal2 = [Signal1(1:end) conj(fliplr(Signal1(2:end)))]./2;
%     else
%
%         Signal2 = [Signal1(1:(end-1)) conj(Signal1(end)) ...
%             conj(fliplr(Signal1(2:(end-1))))]./2;
%     end
% else
%
%     isEven = mod(nRow, 2) == 0;
%
%     if isEven
%
%         Signal2 = [Signal1(1:end); conj(flipud(Signal1(2:end)))]./2;
%     else
%
%         Signal2 = [Signal1(1:(end-1)); conj(Signal1(end)); ...
%             conj(flipud(Signal1(2:(end-1))))]./2;
%     end
% end

end

