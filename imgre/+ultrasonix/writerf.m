function [] = writerf(rfData, dest)
%
%

fid = fopen(dest, 'w');

if ndims(rfData) == 3
    
    [linesPerFrame samplesPerLine numOfChannels] = size(rfData);
    for line = 1:linesPerFrame
        for channel = 1:numOfChannels
 
            fwrite(fid, rfData(line,:,channel),'int16');
        end
    end
    
elseif ndims(rfData) == 2
    
    [linesPerFrame samplesPerLine] = size(rfData);
    for line = 1:linesPerFrame
       
        fwrite(fid, rfData(line,:),'int16');
    end
end

fclose(fid);



    


