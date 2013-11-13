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

U_0 = max(abs(cumtrapz(conv(excScale.*excitation,impScale.*impulse_response)./fs./...
    rho./fs)));

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
plot(AxPoints(3,:), abs(sim_ax)); hold on;
plot(AxPoints(3,:), sol_ax,'r');

%% CALCULATE SIMULATED SOLUTIONS FROM CALC_HP

[hp_ax, t0] = calc_hp(PistonTx, AxPoints.');

figure;
plot(AxPoints(3,:), max(abs(hp_ax(10000:15000,:))),'g');

%% DEFINE AND SIMULATE REFLECTIVE WALL

N = 5120;
Dim = [0.005 0.005];
R = 1;

[PosX, PosY, PosZ] = ndgrid(linspace(0, Dim(1), round(sqrt(N))), ...
    linspace(0, Dim(2), round(sqrt(N))), 0);
WallPos = bsxfun(@plus, [PosX(:) PosY(:) PosZ(:)], [-Dim(1)/2 -Dim(2)/2 R]);
WallAmp = ones(round(sqrt(N))^2, 1);

[scat, t0] = calc_scat(PistonTx, PistonTx, WallPos, WallAmp);
scat = scat.';


%% DEFINE AND SIMULATE SINGLE SCATTERER

R = 1;

SinglePos = [0 0 R];

% rxDepth = 0.10;

Tx = PistonTx;
Rx = PistonTx2;
Rad = radius/2;
SingleAmp = 1;%/(pi*Rad^2);

[scat, t0] = calc_scat(Tx, Rx, SinglePos, SingleAmp);
scat = scat.';
% scat = padarray(scat.', [0 round(t0*fs)], 'pre');
% scat = padarray(scat, [0 nSample - size(scat, 2)], 'post');

U_r = cumtrapz(deconvwnr(scat, impScale.*impulse_response).*fs./fs);
%plot(U_r);
U_r = max(abs(U_r(5000:10000)));
F_r = deconvwnr(scat, impScale.*impulse_response).*fs;
F_r = max(abs(F_r(5000:10000)));

pref = 1e-6;
iref = pref^2/(rho*c);
wref = iref*4*pi;

p1 = calc_hp(Tx, [0 0 1]);
P1 = max(abs(p1));
SL = 20*log10(P1/sqrt(2)/pref)

TL1 = 10*log10(4*pi*R^2);
TL2 = TL1;

pr1 = piston_ax_mag(1, 2*pi*f0/c, Rad, U_r);
PR1 = max(abs(pr1));
EL = 20*log10(PR1/sqrt(2)/pref);
EL2 = 10*log10((F_r/(pi*Rad^2))^2/(2*rho*c)/iref)
EL3 = 20*log10((F_r/(pi*Rad^2))/sqrt(2)/pref)
%EL2 = 10*log10((U_r*rho*c)^2/(2*rho*c)/iref)

TS = EL2 - SL + TL1 + TL2
sigma = 10^(TS/10)*4*pi;




