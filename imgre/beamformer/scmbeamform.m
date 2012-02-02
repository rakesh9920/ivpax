function [img] = scmbeamform(rfcube, rmat, tmat)

samplingfreq = 40*10^6;
%savedelay = 5000*10^-9;
savedelay = 0;

timeres = samplingfreq^-1;
[numofangles, numofsamples, numofchannels] = size(rfcube);
numofangles = int16(numofangles);
numofsamples = int16(numofsamples);
distinsamples = int16((numofsamples + round(savedelay/timeres))/2);

save = int16(savedelay/timeres);

rac.top = 4;
rac.mid = 68;
rac.btm = 128;
rac.vmid = 50;

rcurve = curve(100*(1:double(distinsamples))/double(distinsamples),rac); % CHECK THIS

R = Composite(4);
T = Composite(4);
I = Composite(4);

R{1} = rmat(1:64,:,:);
R{2} = rmat(65:128,:,:);
R{3} = rmat(129:192,:,:);
R{4} = rmat(193:256,:,:);

T{1} = tmat(1:64,:,:);
T{2} = tmat(65:128,:,:);
T{3} = tmat(129:192,:,:);
T{4} = tmat(193:256,:,:);

I{1} = zeros(64,distinsamples - save,'int32');
I{2} = zeros(64,distinsamples - save,'int32');
I{3} = zeros(64,distinsamples - save,'int32');
I{4} = zeros(64,distinsamples - save,'int32');

clear rmat tmat

spmd
    switch (labindex)
        case 1
            start = 1;
            stop = 64;
        case 2
            start = 65;
            stop = 128;
        case 3
            start = 129;
            stop = 192;
        case 4
            start = 193;
            stop = 256;
    end

    for line = start:stop
        
        tic;
        for sample = 1:(distinsamples - save)
            
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
                for ang = 1:numofangles
                    
                    total = R(line-start+1,sample,channel) + T(line-start+1,sample,ang) - save;
                    
                    if (total > numofsamples || total < 1)
                        continue
                    end
                    
                    I(line-start+1,sample) = I(line-start+1,sample) + int32(rfcube(ang,total,channel));
                end
            end
        end
        toc; drawnow;
    end
end

img = zeros(256,distinsamples - save,'int32');
img(1:64,:) = I{1};
img(65:128,:) = I{2};
img(129:192,:) = I{3};
img(193:256,:) = I{4};

end

