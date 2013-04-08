function [velocityEstimate] = ftdoppler(BfMatrix, TxDistance, nCompare, nTimeSample)
% Doppler flow estimate using full cross-correlation

[nSample nPoint nFrame] = size(BfMatrix);
velocityEstimate = zeros(1, nPoint, nFrame);

% global constants
global SOUND_SPEED SAMPLE_FREQUENCY PULSE_REPITITION_RATE
if isempty(SOUND_SPEED)
    SOUND_SPEED = 1500;
end
if isempty(SAMPLE_FREQUENCY)
    SAMPLE_FREQUENCY = 40e6;
end
if isempty(PULSE_REPITITION_RATE)
    PULSE_REPITITION_RATE = 60;
end

% make comparison and time sample windows odd so that the midpoint is an
% integer
if mod(nCompare, 2) == 0
    nCompare = nCompare + 1;
end
if mod(nTimeSample, 2) == 0
    nTimeSample = nTimeSample + 1;
end

TxSample = round(TxDistance/SOUND_SPEED*SAMPLE_FREQUENCY);

progressBar = upicbar('Calculating velocity...');
for frame = 1:(nFrame - 1)
    
    for point1 = 1:nPoint
        
        upicbar(progressBar, ((frame - 1)*nPoint + point1)/((nFrame - 1)...
            *nPoint));
        
        % calculate windowed time signal for beamformed point 1
        txDelay1 = TxSample(1,point1);
        BfSignal1 = windowsignal(BfMatrix(:, point1, frame), ...
            txDelay1, nTimeSample);
        
        %plot(BfSignal1); hold on;
        
        % calculate window of beamformed points to compare to
        compareWinFront = point1 - (nCompare - 1)/2;
        compareWinBack = point1 + (nCompare - 1)/2;
        
        if compareWinFront < 1
            compareWinFront = point1;
        end
        if compareWinBack > nPoint
            compareWinBack = nPoint;
        end
        
        XcorrList = zeros(1, compareWinFront - compareWinBack + 1);
        
        for point2 = compareWinFront:compareWinBack
            
            txDelay2 = TxSample(1,point2);
            
            BfSignal2 = windowsignal(BfMatrix(:, point2, frame + 1), ...
                txDelay2, nTimeSample);
            
            XcorrList(point2-compareWinFront+1) = max(xcorr(BfSignal1, BfSignal2, 'coeff'));
            
            %plot(vect2, 'r');
        end
        
        [~, index] = max(XcorrList);
        
        point2 = compareWinFront + index - 1;
        delay = TxDistance(1,point2) - TxDistance(1,point1);

        velocityEstimate(1, point1, frame) = delay*PULSE_REPITITION_RATE;
    end
end

end

function [winSignal] = windowsignal(signal, midpoint, winWidth)

nSample = size(signal, 1);

front = midpoint - (winWidth - 1)/2;
back = midpoint + (winWidth - 1)/2;

if front < 1
    front = 1;
end
if back > nSample;
    back = nSample;
end

win = [zeros(front - 1, 1); hanning(back - front + 1); ...
    zeros(nSample - back, 1)];
            
winSignal = signal.*win;

end