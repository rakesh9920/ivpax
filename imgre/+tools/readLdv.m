%% This segment reads the prompts the user to select the binary file
[filename, FPATH]=uigetfile({'*.dat;*.bin;*.dbl*.lvm','Binary Files (*.dat,*.bin,*.dbl)';...
'*.*','All Files (*.*)'},'Please Select Binary File');
fid=fopen([FPATH filename ],'r');
temp=fread(fid,inf,'double');
fs=temp(1); %Hz
num_ch=temp(2); 
for idx=1:num_ch
        idx2=idx+2:num_ch:length(temp);
    data(:,idx)=temp(idx2);
end
n_ch = [1 2];
data(:,n_ch) = 125*data(:,n_ch); % 125 is the scaling factor for LDV sensor.

 scan = data;
time=1/fs:1/fs:(length(scan))/fs;

N=length(data);Ts=1/fs;freq=[0:N-1]/N/Ts;

FT = abs(fft(scan));
plot(time,data), figure(2)
plot(freq,FT),