function [imgmat] = doppler1d(bfm, prms)

soundSpeed = prms.soundSpeed;
timeRes = prms.timeRes;
samplingFreq = prms.samplingFreq;
showProgress = prms.showProgress;
numOfThreads = prms.numOfThreads;
useFilter = prms.useFilter;

[numOfLines, numOfSamples, numOfFrames] = size(bfm);
corrmat = zeros(numOfLines, numOfSamples*2 + 1, numOfFrames - 1);
numOfTimeSteps = floor(numOfSamples/(timeRes*samplingFreq));

if useFilter
    numOfKernels = length(filter);
    kernelWidth = floor(timeRes/numOfKernels);
else
    numOfKernels = 1;
    kernelWidth = timeRes;
end

imgmat = zeros(numOfLines, numOfKernels , numOfFrames - 1,'int16');
samplesPerKernel = kernelWidth*samplingFreq;

xc = zeros(numOfKernels, samplesPerKernel);

for frame = 1:(numOfFrames - 1)
    for line = 1:numOfLines
        
        rf1 = bfm(line, :, frame);
        rf2 = bfm(line, :, frame + 1);
        
        for tstep = 1:numOfTimeSteps
            
            for kernel = 1:numOfKernels
                
                front1 = (kernel - 1)*samplesPerKernel + 1 + (tstep - 1)*numOfKernels*samplesPerKernel;
                back1 = front1 + samplesPerKernel - 1;
                corrSize = (front1 - back1 + 1)*2 + 1;
                
                front2 = (kernel - 1)*corrSize + 1;
                back2 = front2 + corrSize;
                
                xc(kernel, :)  = xcorr(rf1(front1:back1), rf2(front1:back1), 'coeff');
            end
            
            if useFilter
                filteredxc = filter*xc;
                corrmat(line, front2:back2, frame) = filteredxc;
                [val ind] = max(filteredxc);
                imgmat(line, kernel, frame) = ind - (front - back + 1);
            else
                corrmat(line, front2:back2, frame) = xc;
                [val ind] = max(xc);
                imgmat(line, kernel, frame) = ind - (front - back + 1);
        end
    end
end


end