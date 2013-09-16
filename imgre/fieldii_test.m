%
%

import fieldii.*
addpath ./bin/

field_init;
%%

global SOUND_SPEED
SOUND_SPEED = 1500;

f0 = 5e5;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

tx = xdc_linear_array(10, 0.001, 0.001, 0.001, 2, 2, [0 0 0]);
impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');

xdc_impulse(tx, impulse_response);
xdc_excitation(tx, sin(2*pi*f0*(0:1/fs:2/f0)));
xdc_focus(tx, 0, [0 0 300]);

[X, Y, Z] = ndgrid(-0.01:0.0001:0.01, 0, 0:0.0001:0.02);
grd = [X(:) Y(:) Z(:)];


%%

h = calc_hp(tx, grd);
h = reshape(h, [], 201, 1, 201);

%%
for i = 1:size(h,1)
    mesh(X, Z, squeeze(h(i,:,1,:)));
    axis([-0.01 0.01 0 0.02 -1e-9 1e-9]);
    pause(0.01);
end

%%
for bl = 1:10000:length(grd)
    
end