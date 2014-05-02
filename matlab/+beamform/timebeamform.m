function [bfmat] = timebeamform(rfcube, options)

if nargin <= 1
    options = [];
end

% pull general parameters from options struct
samplefreq = bfmget(options, 'SampleFreq', 40e6);
pitch = bfmget(options, 'ArrayPitch', 300e-6);
wavespeed = bfmget(options, 'SoundSpeed', 1482);
pa = bfmget(options, 'Photoacoustic', false);
alpha = bfmget(options, 'GaussWinAlpha', 1.5);
channelOmit = bfmget(options, 'ChannelOmit', []);
phaseCorrection = bfmget(options, 'PhaseCorrection', zeros(1,128));
mvlength = bfmget(options, 'MVSubarrayLength', 40);
useApod = bfmget(options, 'GaussApodization', false);
useMV = bfmget(options, 'MinimumVariance', false);
useRxCurve = bfmget(options, 'RxApertureCurve', false);
useCF = bfmget(options, 'CoherenceWeighting', false);

% pull dynamic receive curve parameters from options struct
rac.top = bfmget(options, 'RxCurveTop', 10);
rac.mid = bfmget(options, 'RxCurveMid', 68);
rac.btm = bfmget(options, 'RxCurveBtm', 100);
rac.vmid = bfmget(options, 'RxCurveVmid', 52);
rxcurvedepth = bfmget(options, 'RxCurveDepth', 0.055);
rxmaxelements = bfmget(options, 'RxMaxElements', 128);

% calculate other useful variables
timeres = 1/samplefreq;
[numofscanlines, numofsamples, numofchannels] = size(rfcube);
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2; % x location of sensors

if pa
    numoflines = 256;
    %distinsamples = numofsamples;
    distinsamples = round(numofsamples/2);
else
    numoflines = numofscanlines;
    distinsamples = round(numofsamples/2);
end

line2chanratio = numoflines/numofchannels;
numofrows = distinsamples;
xpixelspacing = pitch*numofchannels/numoflines;
ypixelspacing = wavespeed*timeres;

rcurve = curve(100*(1:numofrows)./round(rxcurvedepth/wavespeed/timeres),rac);
rcurve(rcurve > rxmaxelements) = rxmaxelements;

bfmat = zeros(numoflines, numofrows, 'double');
rfcube = double(rfcube);

if useMV
    useApod = false;
    useRxCurve = false;
end

% beamform loop
prog = progress(0,0,'Beamforming');
for line = 1:numoflines
    
    progress(line/numoflines,0,'Beamforming',prog);
    
    x = (line - 1)*xpixelspacing + xpixelspacing/2;
    
    for row = 1:numofrows
        
        y = (row - 1)*ypixelspacing + ypixelspacing/2;
        
        % determine aperture to use and which channels fall in aperture
        if useRxCurve
            % determine aperture to use and which channels fall in aperture
            ap = rcurve(row);
            cstart = round(line/line2chanratio - ap/2);
            if cstart < 1
                cstart = 1;
            end
            cstop = round(line/line2chanratio + ap/2);
            if cstop > numofchannels
                cstop = numofchannels;
            end
            activeChannels = cstart:cstop;
        else
            activeChannels = 1:numofchannels;
        end
        
        % calculate apodization weights if enabled
        if useApod
            win = gausswin(length(activeChannels),alpha)';
            weights = win(activeChannels-cstart+1)';
        else
            weights = ones(1,length(activeChannels))';
        end
        
        % calculate delays (in units of samples)
        receivedelays = sqrt((array(activeChannels)-x).^2 + y^2)./wavespeed/timeres;
        if pa
            %delays = round(receivedelays);% ORIGINAL
            delays = round(receivedelays + y/wavespeed/timeres);
        else
            delays = round(receivedelays + y/wavespeed/timeres);
        end
        
        if ~all(phaseCorrection == 0)
            delays = delays - phaseCorrection(activeChannels);
        end
        
        % find active channels that are in the omit channel vector and
        % disable those channels
        index2 = ismember(activeChannels, channelOmit);
        delays(index2) = [];
        activeChannels(index2) = [];
        weights(index2) = [];
        
        % find delays which exceed number of samples and disable those
        % channels
        index1 = (delays > numofsamples) | (delays < 1);
        if useMV
            delays(index1) = 1;
        else
            delays(index1) = [];
            activeChannels(index1) = [];
            weights(index1) = [];
        end

        % for this row, find the delayed samples, mulitply by weights and
        % sum
        if useMV
            L = mvlength;
            mvno = length(activeChannels) - L + 1;
            
            subind = sub2ind(size(rfcube), ones(1,length(delays)), delays, activeChannels);
            samplemat = rfcube(subind).';
            
            %samplemat(index1) = 0;
            
            obsmat = zeros(L, mvno);
            
            for n = 1:L
                obsmat(n,:) = samplemat(n:(n+mvno-1));
            end
            
            covmat = obsmat*obsmat'./mvno;
            steer = ones(length(covmat),1);
            
            inverse = covmat\steer;
            mvweights = (inverse)/(steer'*inverse);
            
            if useCF
                CF = abs(sum(samplemat))^2./sum(abs(samplemat).^2)./length(samplemat);
            else
                CF = 1;
            end
            bfmat(line, row) = CF*sum(mvweights'*obsmat);
        else
            if pa
                subind = sub2ind(size(rfcube), ones(1,length(delays)), delays, activeChannels);
                bfmat(line,row) = rfcube(subind)*weights;
            else
                subind = sub2ind(size(rfcube), line.*ones(1,length(delays)), delays, activeChannels);
                bfmat(line,row) = bfmat(line,row) + rfcube(subind)*weights;
            end
        end
    end
end

bfmat(isnan(bfmat)) = 0;
end

