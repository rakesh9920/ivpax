
numofsamples = 2678;
numofframes = 195;
numofimages = floor(numofframes/128);
chunksize = 2678*128; %floor(numofimages/16)*128;

rfc = zeros(128, numofsamples, 128, 1, 'int16');

for c = 0:127
    
    cstr = num2str(c);
    switch length(cstr)
        case 1
            cstr = strcat('00', cstr);
        case 2
            cstr = strcat('0', cstr);
    end
    
    path = strcat('./rfdata/ch', cstr, '.daq');
    
    fid = fopen(path);
    rf = int16(fread(fid, inf, 'int16'));
    fclose(fid);
    
    chunk = int16(rf(7:(6 + chunksize)));
    
    rfc(:, :, c + 1, :) = reshape(chunk, 128, numofsamples, 1);
    
    clear chunk rf
end

%%
rfc_b = bandpass(squeeze(rfc(:,:,:,1)),6,4.8,40);

bfmopt = bfmset( ...
    'ArrayPitch', 300e-6, ...
    'CoherenceWeighting', false, ...
    'GaussApodization', false, ...
    'ChannelOmit', [], ... %us: 1 26 90 | pa: 97)
    'GaussWinAlpha', 1.5, ...
    'MinimumVariance', false, ...
    'MVSubarrayLength', 50, ...
    'PhaseCorrection', [], ...
    'RxApertureCurve', false, ...
    'RxCurveBtm', 100, ...
    'RxCurveMid', 68, ...%68
    'RxCurveTop', 10, ...%10
    'RxCurveVmid', 52, ...
    'RxMaxElements', 64, ... %64
    'RxCurveDepth', 0.055, ...
    'SampleFreq', 40e6, ...
    'SoundSpeed', 1494, ...
    'Photoacoustic', false ...
    );

[bfm] = timebeamform(rfc_b, bfmopt);
