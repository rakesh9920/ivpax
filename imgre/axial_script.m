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

RxPos = [((0:127).*300e-6 + 150e-6 - 64*300e-6); zeros(1,128); zeros(1,128)];
FieldPos = [0; 0; 0.02];

%%
daq2mat([], [], prms);
%%
instpre([], [], [], RxPos, FieldPos, 201, prms);
%%
VelEst = instest([], prms);