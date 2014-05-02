function [LdvData, ChData, sampleFreq] = readldv(varargin)
%
%

if nargin > 0
    scale = varargin{1};
else
    scale = 4;
end


[filename, FPATH] = uigetfile({'*.dat;*.bin;*.dbl*.lvm','Binary Files (*.dat,*.bin,*.dbl)';...
    '*.*','All Files (*.*)'},'Please Select Binary File');


fid = fopen([FPATH filename], 'r');
stream = fread(fid, inf, 'double');
fclose(fid);

sampleFreq = stream(1); %Hz
nChannel = stream(2);
nSample = (length(stream) - 2)/nChannel;
raw = zeros(nSample, nChannel);

for ch = 1:nChannel
    idx = ch + 2:nChannel:length(stream);
    raw(:,ch) = stream(idx);
end


LdvData = raw(:,1).'.*scale/4;
ChData = raw(:,2:end).';

%n_ch = [1 2];
%raw(:,n_ch) = raw(:,n_ch);


