%% Data Extraction %%

filename = 'rfdata/beam4.rf'; % path to RF file
header = 'rfdata/beam4.bmh'; % path to BMH file

% Extract RF data from file
hd = readheader(header);
rfc = readrf(filename, hd);

clear filename header;
%% Filtering %%

% Lowpass filter
%rfc_l = lowpass(rfc,10.1,40);

% Bandpass filter
rfc_b = bandpass(rfc,6.6,5.28,40); % 6.6 MHz and 80% FBW
%rfc_b = bandpass(nl1_rfc,8.2,3.28,40);
%rfc_b = bandpass(rfc,10,7,40); % 10 MHz and 70% FBW

% Frequency compounding filter
%rfc_fc = fcfilter(rfc_b,3,6,9,4,40);
%rfc_fc = fcfilter2(rfc_b);

%clear rfc_b;
%% Beamforming %%

bfmopt = bfmset( ...
    'ArrayPitch', 300e-6, ...
    'CoherenceWeighting', false, ...
    'GaussApodization', true, ...
    'ChannelOmit', [], ... %us: 1 26 90 | pa: 97)
    'GaussWinAlpha', 1.5, ...
    'MinimumVariance', false, ...
    'MVSubarrayLength', 50, ...
    'RxApertureCurve', true, ...
    'RxCurveBtm', 100, ...
    'RxCurveMid', 68, ...%68
    'RxCurveTop', 10, ...%10
    'RxCurveVmid', 52, ...
    'RxMaxElements', 64, ... %64
    'RxCurveDepth', 0.055, ...
    'SampleFreq', 160e6, ...
    'SoundSpeed', 1494, ...
    'Photoacoustic', true ...
    );

[bfm] = timebeamform(rfc_b, bfmopt);

clear prm pa;
%% Image Filtering/Processing %%

img = imager(envelope(bfm),30);

