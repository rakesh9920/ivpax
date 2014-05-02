function [signal] = waveformgen(options)

pulseType = options.pulseType;
amplitude = 1;%simget(options, 'Amplitude', 1);
sampleFreq = options.sampleFreq;%simget(options, 'SampleFreq', 40e6);
timeDelay = options.timeDelay;%simget(options, 'TimeDelay', 0);
timeLength = options.timeLength;%simget(options, 'TimeLength', 10e-6);
freq = options.centerFreq;%simget(options, 'Frequency', 1e6);

if ~ischar(pulseType)
    message(error('waveformgen:Invalid pulse type'));
end

t = (-timeDelay):(1/sampleFreq):(timeLength-timeDelay);

switch pulseType
    case 'gaussian'
        %fbw = simget(options, 'GaussFractBandwidth', 0.5);
        fbw = options.fbw;
        signal = amplitude.*gauspuls(t,freq,fbw);
        
    case 'puretone'
        signal = amplitude*sin(2.*pi.*freq.*t);
        
    case 'rectangular'
        winLength = simget(options, 'SquareWindowLength', 5e-6);
        signal = amplitude.*sin(2.*pi.*freq.*t).*rectpuls(t,winLength);
        
    case 'unipolar'
        period = 1/freq;
        signal = amplitude.*sin(2.*pi.*freq.*t).*rectpuls(t-period/4,period/2);
        
    case 'bipolar'
        period = 1/freq;
        signal = amplitude.*sin(2.*pi.*freq.*t).*rectpuls(t-period/2,period);
        
    otherwise
        message(error('waveformgen:Invalid pulse type'));
end

end

