function [r, t] = scmbfdelays(rfcube, header, varargin)

if nargin == 2
    wavespeed = 1482;
    pitch = 300*10^-6;
    samplingfreq = 40*10^6;
    savedelay = 0;
else
    prm = varargin{1};
    wavespeed = prm.wavespeed;
    pitch = prm.pitch;
    samplingfreq = prm.samplingfreq;
    savedelay = prm.savedelay;
end

timeres = samplingfreq^-1;
[numofangles, numofsamples, numofchannels] = size(rfcube);
pixelspacing = 150*10^-6;
distinsamples = (numofsamples + round(savedelay/timeres))/2;

minangle = header.minAngle;
angleincrement = header.angleIncrement;
array = (numofchannels-1)*pitch/2:-pitch:(-numofchannels+1)*pitch/2;

receivedelays = zeros(256, distinsamples, numofchannels,'int16');
transmitdelays = zeros(256, distinsamples, numofangles,'int16');
angles = (minangle + ((1:numofangles) - 1).*angleincrement)/1000;
lat = (pixelspacing/2 + 127*pixelspacing):-pixelspacing:-(pixelspacing/2 + 127*pixelspacing);


prog = progress(0,0,'Delays');
for line = 1:256
    
    progress(line/256,0,'Delays',prog);

    x = lat(line);
    
    for sample = 1:distinsamples
        y = savedelay*wavespeed + sample*timeres*wavespeed; % might be wrong
        
        for channel = 1:numofchannels
            receivedelays(line,sample,channel) = (sqrt((array(channel) - x)^2 + y^2)./wavespeed)/timeres;
        end
        
        for a = 1:numofangles
            transmitdelays(line,sample,a) = ((y*cos(deg2rad(angles(a))) + x*sin(deg2rad(angles(a))))./wavespeed)/timeres...
                + abs(0.0192*tan(deg2rad(angles(a)))*cos(deg2rad(angles(a)))/wavespeed/timeres);
        end
    end
end

r = receivedelays;
t = transmitdelays;

end

