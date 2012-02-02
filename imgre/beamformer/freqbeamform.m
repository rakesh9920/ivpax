function [bfmat] = freqbeamform(rfcube, options)

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
array = (0:pitch:(numofchannels-1)*pitch) + pitch/2;

if pa
    numoflines = 256;
    distinsamples = numofsamples;
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

% initialize variables
bfmat = zeros(numoflines, numofrows, 'double');
ftlength = 2^nextpow2(numofsamples);
ftcube = fft(double(rfcube), ftlength, 2); % cube of ffts
ftcube(:,ftlength/2:ftlength,:) = 0; % remove negative frequencies
k = 1i.*2.*pi.*samplefreq.*repmat(((1:ftlength) - 1),128,1)./ftlength; % frequencies

if useMV
    %mvno = numofchannels - mvlength + 1;
    steer = ones(mvlength,1);
    useApod = false;
    useRxCurve = false;
    ftmat = squeeze(ftcube(1,1:ftlength/2,1:numofchannels)).';
end

% beamform loop
prog = progress(0,0,'Beamforming');
for line = 1:numoflines
    
    progress(line/numoflines,0,'Beamforming',prog);
    
    x = (line - 1)*xpixelspacing + xpixelspacing/2;
    
    for row = 1:numofrows
        
        y = (row - 1)*ypixelspacing + ypixelspacing/2;
        
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
            weights = win(activeChannels-cstart+1);
        else
            weights = ones(length(activeChannels));
        end
        
        % calculate delays (in units of time)
        receivedelay = sqrt((array(activeChannels)-x).^2 + y^2)./wavespeed;
        if pa
            delays = receivedelay;
        else
            delays = receivedelay + y/wavespeed;
        end
        
        % find delays which exceed total signal time, disable those
        % channels
        if ~useMV
            index1 = delays > numofsamples*timeres;
            delays(index1) = [];
            activeChannels(index1) = [];
            weights(index1) = [];
        end
   
        % find active channels that are in the omit channel vector and
        % disable those channels
        index2 = ismember(activeChannels, channelOmit);
        delays(index2) = [];
        activeChannels(index2) = [];
        weights(index2) = [];
        
        % normalize delays to minimum delay
        delays = delays - min(delays);
        
        % form fft mat of active channels and delay mat for their
        % corresponding delays
        if ~useMV
            if pa
                ftmat = squeeze(ftcube(1,1:ftlength/2,activeChannels));
            else
                ftmat = squeeze(ftcube(line,1:ftlength/2,activeChannels));
            end
            % if only one active channel, squeeze will remove an extra
            % dimension
            if length(activeChannels) > 1
                ftmat = ftmat.';
            end
        end
        
        delaymat = repmat(delays.', 1, ftlength/2);
        
        freqchanmat = exp(k(activeChannels,1:ftlength/2).*delaymat).*ftmat(activeChannels,:);
        
        if useMV
            mvno = length(activeChannels) - mvlength + 1;
            timechanmat = real(ifft(freqchanmat,ftlength,2));
            samplemat = timechanmat(:,row);
            obsmat = zeros(mvlength, mvno);
            
            for n = 1:mvlength
                obsmat(n,:) = samplemat(n:(n+mvno-1));
            end
            
            covmat = obsmat*obsmat'./mvno;
            %inverse = inv(covmat);
            
            inverse = covmat\steer;
            mvweights = (inverse)/(steer'*inverse);
            
            if useCF
                CF = abs(sum(samplemat))^2./sum(abs(samplemat).^2)./length(samplemat);
            else
                CF = 1;
            end
            
            bfmat(line, row) = CF*sum(mvweights'*obsmat);
        else
            ftbfsig = weights*freqchanmat;
            bfsig = real(ifft(ftbfsig,ftlength));
            
            if pa
                bfmat(line, row) = bfsig(row);
            else
                bfmat(line, row) = bfsig(row*2);
            end
        end       
    end
end

end

