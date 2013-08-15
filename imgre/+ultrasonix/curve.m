function [yi] = curve(xi, prm)

x = [0 prm.vmid 100];
y = [prm.top prm.mid prm.btm];

ext = find(xi > 100);

if ~isempty(ext)
   for ind = ext
       xi(ind) = 100;
   end
end

yi = interp1(x,y,xi,'cubic');

end

