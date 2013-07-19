%% import and set parameters
import tools.*
import ultrasonix.*
import flow.*

prms = containers.Map();
prms('bfmethod') = 'frequency';
prms('planetx') = true;
prms('filter') = true;
prms('bw') = 5.2e6;
prms('fc') = 6.6e6;
prms('progress') = true;
prms('recombine') = true;
prms('averaging') = 16;
prms('nsum') = 16;
prms('interpolate') = 16;
prms('interleave') = 0;

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
RxPosL = RxPos(:,1:16);
RxPosR = RxPos(:,113:128);
FieldPos = [0; 0; 0.02];
%% filter DAQ data
daq2mat([], [], prms);
%% split RF data into L/R groups
dirname = 'data/15hz/tx2000/matf/';
for i = 21:40
   filename = strcat('RFF00', num2str(i), '.mat');
   load(strcat(dirname, filename));
   RfMatFL = RfMatF(1:16,:,:);
   RfMatFR = RfMatF(113:128,:,:);
   save(strcat(dirname, 'L/', filename), 'RfMatFL');
   save(strcat(dirname, 'R/', filename), 'RfMatFR');
end
%% preprocessing for full aperture (instantaneous estimate) 
instpre([], [], [], RxPos, FieldPos, 801, prms);
%% preprocessing for L aperture (instantaneous estimate) 
instpre([], [], [], RxPosL, FieldPos, 801, prms);
%% preprocessing for R aperture (instantaneous estimate) 
instpre([], [], [], RxPosR, FieldPos, 801, prms);
%% velocity estimate (instantaneous estimate) 
[VelEstL, BfAvgL] = instest([], prms);
[VelEstR, BfAvgR] = instest([], prms);
%% construct component velocity
theta = atan(2/1.7);
P = [-cos(theta) sin(theta); 
    cos(theta) sin(theta)];
ProjVel = [VelEstL; VelEstR];
CompVel = inv(P)\ProjVel;
%% preprocessing (max correlation estimate)
maxcorrpre([], [], [], RxPos, FieldPos, 21, 1e-7, 201, prms);
%% velocity estimate (max correlation estimate)
[VelEst, BfAvg] = maxcorrest([], 21, 1e-7, prms);
%% quiver plot movie

for frame = 1:size(CompVel,2)
    quiver(0, 0.02, CompVel(1,frame), CompVel(2,frame));
    axis([-0.0005 0.0005 0.0195 0.0205]);
    M(frame) = getframe(gcf);
end

