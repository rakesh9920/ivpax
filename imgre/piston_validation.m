import fieldii.*
import f2plus.*
addpath ./bin/

%% INITIALIZE FIELD II

rho = 1000; % kg/m^3
c = 1540;
fs = 100e6;
f0 = 5e6;
att = 0; % 176 % in dB/m
freq_att = 0;
att_f0 = 5e6;
U_0 = 1;

field_init(-1);

set_field('c', c);
set_field('fs', fs);
set_field('att', att);
set_field('freq_att', freq_att);
set_field('att_f0', att_f0);
set_field('use_att', 1);

impulse_response = sin(2*pi*f0*(0:1/fs:2/f0));
impulse_response = impulse_response.*(hanning(length(impulse_response)).');
excitation = 1.*sin(2*pi*f0*(0:1/fs:1000/f0));

%% DEFINE FUNCTIONS TO CALCULATE PISTON FIELD (ANALYTICAL SOLUTION)

piston_ax_mag = @(r, k, a, U_0) 2*rho*c*U_0.*abs(sin(1/2.*k.*r.*(sqrt(1 + ...
    (a./r).^2) - 1)));

piston_ff_mag = @(r, theta, k, a, U_0) piston_ax_mag(r, k, a, U_0).*...
    2.*besselj(1, k.*a.*sin(theta))./(k.*a.*sin(theta));

%% DEFINE CIRCULAR PISTON ARRAY

radius = 5/1000;
elementSize = 0.05/1000;
impScale = 1;
excScale = 1;

PistonTx = xdc_piston(radius, elementSize);

xdc_impulse(PistonTx, impScale.*impulse_response);
xdc_excitation(PistonTx, excScale.*excitation);
xdc_focus_times(PistonTx, 0, zeros(1, xdc_nphys(PistonTx)));

U_0 = max(abs(cumtrapz(conv(excScale.*excitation,impScale.*impulse_response)./...
    rho.*(1/fs))));
%% DEFINE GRID POINTS

AxPoints = [zeros(1, 1000); zeros(1, 1000); linspace(0, 0.10, 1000)];
theta = linspace(-pi/2, pi/2, 1000);
R = 0.10;
FFPoints = R.*[sin(theta); zeros(1, 1000); cos(theta)];
    
%% CALCULATE ANALYTICAL SOLUTIONS

sol_ax = piston_ax_mag(AxPoints(3,:), 2*pi*f0/c, radius, U_0);
sol_ff = piston_ff_mag(R.*ones(1,1000), theta, 2*pi*f0/c, radius, U_0);

%% CALCULATE SIMULATED SOLUTIONS FROM SPATIAL IMPULSE RESPONSE

[SIR, t0] = calc_h(PistonTx, AxPoints.');

t = (0:(size(SIR,1)- 1)).*1/fs + t0;
t = t.';
sim_ax = 1i*2*pi*f0*U_0*rho.*sum(bsxfun(@times, SIR, exp(-1i*2*pi*f0.*t)));

figure;
plot(abs(sim_ax)); hold on;
plot(sol_ax,'r');

%% CALCULATE SIMULATED SOLUTIONS FROM CALC_HP

[hp_ax, t0] = calc_hp(PistonTx, AxPoints.');

figure;
plot(max(abs(hp_ax(10000:15000,:))));



