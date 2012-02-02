function [bfmat] = mfbeamform(rfcube, varargin)

if class(rfcube) ~= 'cell'
    return
end

if nargin == 1
    timeres = 25e-9;
    pitch = 300e-6;
    wavespeed = 1482;
    savedelay = 0;
    pa = false;
else
    prm = varargin{1};
    timeres = 1/prm.samplingfreq;
    pitch = prm.pitch;
    wavespeed = prm.wavespeed;
    
    if isfield(prm,'savedelay')
        savedelay = prm.savedelay;
    else
        savedelay = 0;
    end
    
    if nargin == 3
        pa = varargin{2};
    else
        pa = false;
    end
end

numoffocus = size(rfcube, 2);
[numoflines, numofsamples, numofchannels] = size(rfcube{1});

pixelspacing = 150e-6;
save = int16(savedelay/timeres);
array = 0:pitch:numofchannels*pitch;

distinsamples = int16((numofsamples + save)/2);
samplesperfocus = floor((distinsamples-save)/numoffocus);


if pa
    numoflines = 256;
    distinsamples = int16(numofsamples + save);
end

bfmat = zeros(numoflines, distinsamples - save, 'int32');

rac.top = 4;
rac.mid = 68;
rac.btm = 128;
rac.vmid = 50;
rcurve = curve(100*(1:double(distinsamples))/double(distinsamples),rac);

prog = progress(0,0,'Beamforming');

for line = 1:numoflines
    
    progress(line/numoflines,0,'Beamforming',prog);
    
    x = (line - 1)*pixelspacing;
    
    for focus = 1:numoffocus
        
        sstart = samplesperfocus*(focus - 1) + 1;
        if focus == numoffocus
            sstop = distinsamples - save;
        else
            sstop = sstart + samplesperfocus - 1;
        end
        
        for sample = sstart:sstop
 
            y = savedelay*wavespeed + double(sample)*timeres*wavespeed;
            ap = rcurve(sample);
            
            cstart = int16(line/2 - ap/2);
            if cstart < 1
                cstart = 1;
            end
            cstop = int16(line/2 + ap/2);
            if cstop > 128
                cstop = 128;
            end
            
            for channel = cstart:cstop
                
                receivedelay = (sqrt((array(channel) - x)^2 + y^2)/wavespeed)/timeres;
                
                if pa
                    total = receivedelay - save;
                else
                    transmitdelay = y/wavespeed/timeres;
                    total = transmitdelay + receivedelay - save;
                end
                
                if (total < 1 || total > numofsamples)
                    continue;
                end
                
                if pa
                    bfmat(line,sample) = bfmat(line,sample) + int32(rfcube{focus}(1,total,channel));
                else
                    bfmat(line,sample) = bfmat(line,sample) + int32(rfcube{focus}(line,total,channel));
                end
            end
        end
    end
end

