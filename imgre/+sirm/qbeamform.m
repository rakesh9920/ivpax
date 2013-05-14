function [bfline] = qbeamform(rxsignals, txpts, rxpts, fldpts)

numfldpts = size(fldpts,2);
[numsigs siglength numinst] = size(rxsignals);
soundspeed = 1500;
sampfreq = 40e6;

txdist = sqrt(sqdistance(txpts, fldpts));
rxdist = sqrt(sqdistance(rxpts, fldpts));
totaldist = rxdist + repmat(txdist,4,1);

bfline = zeros(1, numfldpts, numinst);

for inst = 1:numinst
    for fp = 1:numfldpts
        
        dist = totaldist(:, fp);
        
        delays = round(dist./soundspeed.*sampfreq);
        
        sum = 0;
        for d = 1:length(delays)
            if delays(d) > size(rxsignals, 2) || delays(d) < 1
                continue
            end
            sum = sum + rxsignals(d, delays(d), inst);
        end
        
        bfline(1, fp, inst) = sum;
    end
end
