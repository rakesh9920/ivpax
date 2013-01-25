function [imgmat] = doppler1d(bfm, prms)

soundSpeed = prms.soundSpeed;
timeRes = prms.timeRes;
samplingFreq = prms.samplingFreq;
showProgress = prms.showProgress;
numOfThreads = prms.numOfThreads;
useFilter = prms.useFilter;
filter = prms.filter;

[numOfLines, numOfSamples, numOfFrames] = size(bfm);
numOfTimeSteps = floor(numOfSamples/(timeRes*samplingFreq));

if useFilter
    numOfKernels = length(filter);
    kernelWidth = floor(floor(numOfSamples/numOfTimeSteps)/numOfKernels)/samplingFreq;
else
    numOfKernels = 1;
    kernelWidth = timeRes;
end

samplesPerKernel = kernelWidth*samplingFreq;

corrmat = zeros(numOfLines, numOfTimeSteps*(samplesPerKernel*numOfKernels*2 - 1), numOfFrames - 1);
imgmat = zeros(numOfLines, numOfTimeSteps , numOfFrames - 1,'int16');



for frame = 1:(numOfFrames - 1)
    
    rf1temp = bfm(:, :, frame);
    rf2temp = bfm(:, :, frame + 1);
    parfor line = 1:numOfLines
        
        rf1 = rf1temp(line, :);
        rf2 = rf2temp(line, :);
        
        imgtemp = zeros(1, numOfTimeSteps, 'int16');
        corrtemp = zeros(1, numOfTimeSteps*(samplesPerKernel*numOfKernels*2 - 1));
        xc = zeros(numOfKernels, 2*samplesPerKernel - 1);
        
        for tstep = 1:numOfTimeSteps
            
            for kernel = 1:numOfKernels
                
                front1 = (kernel - 1)*samplesPerKernel + 1 + (tstep - 1)*numOfKernels*samplesPerKernel;
                
                back1 = front1 + samplesPerKernel - 1;
                
                corrSize = (back1 - front1 + 1)*2 - 1;
                
                front2 = (kernel - 1)*corrSize + 1;
                back2 = front2 + corrSize - 1;
                
                xc(kernel, :)  = xcorr(rf1(front1:back1), rf2(front1:back1), 'coeff');
            end
            
            if useFilter
                filteredxc = filter*xc;
                corrtemp(1, front2:back2) = filteredxc;
                [val ind] = max(filteredxc);
                imgtemp(1, tstep) = ind - samplesPerKernel;
            else
                corrtemp(1, front2:back2) = xc;
                [val ind] = max(xc);
                imgtemp(1, tstep) = ind - samplesPerKernel;
            end
        end
        
        corrmat(line, :, frame) = corrtemp;
        imgmat(line, :, frame) = imgtemp;
    end
end


end