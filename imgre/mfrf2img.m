%% Data Extraction %%

filename1 = 'rfdata/lum10.rf'; % path to RF file
header1 = 'rfdata/lum10.bmh'; % path to BMH file
filename2 = 'rfdata/lum15.rf'; % path to RF file
header2 = 'rfdata/lum15.bmh'; % path to BMH file
filename3 = 'rfdata/lum25.rf'; % path to RF file
header3 = 'rfdata/lum25.bmh'; % path to BMH file
filename4 = 'rfdata/lum35.rf'; % path to RF file
header4 = 'rfdata/lum35.bmh'; % path to BMH file

% Extract RF data from file
hd1 = readheader(header1);
rfc1 = readrf(filename1, hd1);
hd2 = readheader(header2);
rfc2 = readrf(filename2, hd2);
hd3 = readheader(header3);
rfc3 = readrf(filename3, hd3);
hd4 = readheader(header4);
rfc4 = readrf(filename4, hd4);

clear filename1 filename2 filename3 filename4 header1 header2 header3 header4;
%% Filtering %%

% Lowpass filter
%rfc_l = lowpass(rfc,10.1,40);

% Bandpass filter
rfc_b1 = bandpass(rfc1,6.6,7,40);
rfc_b2 = bandpass(rfc2,6.6,7,40);
rfc_b3 = bandpass(rfc3,6.6,7,40);
rfc_b4 = bandpass(rfc4,6.6,7,40);

% Frequency compounding filter
%rfc_fc = fcfilter(rfc_b,3,6,9,4,40);
rfc_fc1 = fcfilter2(rfc_b1);
rfc_fc2 = fcfilter2(rfc_b2);
rfc_fc3 = fcfilter2(rfc_b3);
rfc_fc4 = fcfilter2(rfc_b4);

rfc_fc{1} = rfc_fc1;
rfc_fc{2} = rfc_fc2;
rfc_fc{3} = rfc_fc3;
rfc_fc{4} = rfc_fc4;

clear rfc_b1 rfc_b2 rfc_b3 rfc_b4 rfc_fc1 rfc_fc2 rfc_fc3 rfc_fc4;
%% Beamforming %%

prm.wavespeed = 1540;
prm.samplingfreq = 40e6;
prm.pitch = 300e-6;
prm.savedelay = 0;
pa = false;

%bfm = mfbeamform(rfc_fc, prm, pa);
bfm1 = bmbeamform(rfc_fc{1}, prm, pa);
bfm2 = bmbeamform(rfc_fc{2}, prm, pa);
bfm3 = bmbeamform(rfc_fc{3}, prm, pa);
bfm4 = bmbeamform(rfc_fc{4}, prm, pa);

clear prm pa;
%% Image Filtering/Processing %%

img = imager(envelope(bfm));

