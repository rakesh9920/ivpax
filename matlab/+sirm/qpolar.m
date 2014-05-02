function [dbamps] = qpolar(angles, amps, db, varargin)

dbamps = 20.*log10(abs(amps)./max(abs(amps)));
dbamps(dbamps < db) = db;
dbamps = dbamps - db;

if nargin == 4
    polar(angles, dbamps, varargin{1});
else
    polar(angles, dbamps);
end


end

