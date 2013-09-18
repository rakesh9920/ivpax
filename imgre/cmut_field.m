%
%

import fieldii.*
import f2plus.*
addpath ./bin/

global SOUND_SPEED SAMPLE_FREQUENCY
SOUND_SPEED = 1500;
SAMPLE_FREQUENCY = 50e6;

f0 = 6e6;
fs = 100e6;
set_field('c', SOUND_SPEED);
set_field('fs', fs);

[CMUT, Centers] = xdc_1d_cmut();

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
xdc_impulse(CMUT, impulse_response);

xdc_excitation(CMUT, sin(2*pi*f0*(0:1/fs:1/f0)));

xdc_focus(CMUT, 0, [0 0 0.01]);

[X, Y, Z] = ndgrid(-0.005:0.00005:0.005, 0, 0:0.00005:0.02);
grd = [X(:) Y(:) Z(:)];

FieldPressure = calc_hp(CMUT, grd);
FieldPressure = reshape(FieldPressure, [], 201, 1, 401);

%%
f = 1;
for i = 1:6:size(FieldPressure,1)
    mesh(X, Z, squeeze(FieldPressure(i,:,1,:)));
    caxis([-0.1e-11 0.1e-11]);
    view(az, el)
    axis([-0.005 0.005 0 0.02 -0.5e-11 0.5e-11]);
    daspect([1 1 1e-9])
    xlabel('lateral [m]');
    ylabel('axial [m]');
    zlabel('pressure (relative) [Pa]');
    drawnow;
    Vid(f) = getframe(gcf);
    pause(0.001);
    f = f + 1;
end

%%
for bl = 1:10000:length(grd)
    
end