%
%

R = 0.005;         %  Radius of blood vessel [m]
x_range=0.08;    %  x range for the scatterers  [m]
y_range=2*R;     %  y range for the scatterers  [m]
z_range=2*R;     %  z range for the scatterers  [m]
z_offset=0.06;   %  Offset of the mid-point of the scatterers [m]

%  Set the number of scatterers. It should be roughly
%  10 scatterers per cubic wavelength

c=1540;    %  Ultrasound propagation velocity [m/s]
f0=3e6;    %  Center frequency of transducer  [Hz]
lambda=c/f0;
N=round(10*x_range/(5*lambda)*y_range/(5*lambda)*z_range/(lambda*2));
disp([num2str(N),' Scatterers'])

%  Generate the coordinates and amplitude
%  Coordinates are rectangular within the range.
%  The amplitude has a Gaussian distribution.

x=x_range*(rand(1,N)-0.5);
y=y_range*(rand(1,N)-0.5);
z=z_range*(rand(1,N)-0.5);

%  Find which scatterers that lie within the blood vessel

r=(y.^2+z.^2).^0.5;
within_vessel= r < R;

%  Assign an amplitude and a velocity for each scatterer

v0=1;   %  Largest velocity of scatterers [m/s]
velocity=v0*(1-(r/R).^2).*within_vessel;

blood_to_stationary= 10;   %  Ratio between amplitude of blood to stationary tissue
amp=randn(1,N).*((1-within_vessel) + within_vessel*blood_to_stationary);
amp=amp';