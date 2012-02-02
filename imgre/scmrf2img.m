%% Data Extraction %%

filename = 'rfdata/trip_sc3.rf'; % path to RF file
header = 'rfdata/trip_sc3.sch'; % path to BMH file

% Extract RF data from file
hd = readheader(header);
rfc = readrf(filename, hd);

clear filename header
%% Filtering %%

% Bandpass filter
rfc_b = bandpass(rfc,6.6,7,40);

% Frequency compounding filter
rfc_fc = fcfilter2(rfc_b);

clear rfc_b;
%% Beamforming Delays %%

prm.wavespeed = 1540;
prm.samplingfreq = 40e6;
prm.pitch = 300e-6;
prm.savedelay = 0;

[r t] = scmbfdelays(rfc_fc,hd,prm);

clear prm pa
%% Beamforming %%

%matlabpool 4
bfm = scmbeamform(rfc_fc,r,t);
%matlabpool close
%% Image Filtering/Processing %%

img = imager(envelope(bfm));

