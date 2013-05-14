%%
addpath ./beamformer/
addpath ./imager/
%%
numofsamples = 2600;
numofchannels = 128;
%numofframes = 1;
framesperimage = 128;
numofimages = 1;
cmap = [0 16 32 48 64 80 96 112 1 17 33 49 65 81 97 113 2 18 34 50 66 82 98 114 ...
3 19 35 51 67 83 99 115 4 20 36 52 68 84 100 116 5 21 37 53 69 85 101 117 ...
6 22 38 54 70 86 102 118 7 23 39 55 71 87 103 119 8 24 40 56 72 88 104 120 ...
9 25 41 57 73 89 105 121 10 26 42 58 74 90 106 122 11 27 43 59 75 91 107 ...
123 12 28 44 60 76 92 108 124 13 29 45 61 77 93 109 125 14 30 46 62 78 94 ...
110 126 15 31 47 63 79 95 111 127];
%chunksize = 2678*128; %floor(numofimages/16)*128;
%%
rfc = zeros(numofchannels, numofsamples, 128, 1, 'int16');
fid = zeros(1,128);
header = zeros(6,128);

for c = 1:numofchannels
    cstr = num2str(c-1);
    switch length(cstr)
        case 1
            cstr = strcat('00', cstr);
        case 2
            cstr = strcat('0', cstr);
    end
    
    path = strcat('./rfdata/phantom1/ch', cstr, '.daq');
    fid(c) = fopen(path);
    header(:,c) = fread(fid(c), 6, 'int16');
end
%%
for c = 1:numofchannels

    rf = fread(fid(c), numofsamples*framesperimage*numofimages, 'int16');
    %rfc(:, :, c, :) = reshape(rf, numofsamples, 128, numofimages).';
    rfc(:, :, cmap(c)+1) = reshape(rf, numofsamples, 128).';
    %rfc(:,cmap(c)+1) = rf;
    
end
%%
for c = 1:numofchannels
    fclose(fid(c));
end
%%
rfc_b = bandpass(rfc,6.6,5.2,40);
%%
bfmopt = bfmset( ...
    'ArrayPitch', 300e-6, ...
    'CoherenceWeighting', false, ...
    'GaussApodization', false, ...
    'ChannelOmit', [], ... %us: 1 26 90 | pa: 97)
    'GaussWinAlpha', 1.5, ...
    'MinimumVariance', false, ...
    'MVSubarrayLength', 50, ...
    'PhaseCorrection', [], ...
    'RxApertureCurve', true, ...
    'RxCurveBtm', 100, ...
    'RxCurveMid', 68, ...%68
    'RxCurveTop', 10, ...%10
    'RxCurveVmid', 52, ...
    'RxMaxElements', 64, ... %64
    'RxCurveDepth', 0.055, ...
    'SampleFreq', 40e6, ...
    'SoundSpeed', 1540, ...
    'Photoacoustic', false ...
    );

[bfm] = timebeamform(rfc_b, bfmopt);
