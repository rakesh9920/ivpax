function [bfline] = qbeamform(rxsignals, txpts, rxpts, fldpts)

numfldpts = size(fldpts,2);
[numsigs siglength] = size(rxsignals);
soundspeed = 1500;
sampfreq = 40e6;

txdist = sqrt(sqdistances(txpts, fldpts));
rxdist = sqrt(sqdistances(rxpts, fldpts));
totaldist = rxdist + repmat(txdist,4,numfldpts);

bfline = zeros(1, numfldpts);

for fp = 1:numfldpts
    
    dist = totaldist(:, fp);
    
    delays = round(dist./soundspeed.*sampfreq);
    
    sum = 0;
    for d = 1:length(delays)
        if delays(d) > size(rxsignals, 2) || delays(d) < 1
            continue
        end
        sum = sum + rxsignals(d, delays(d));
    end

    bfline(fp) = sum;
end

