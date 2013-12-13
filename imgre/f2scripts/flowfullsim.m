%

import f2plus.sct_uniform_flow
import f2plus.run_calc_multi
import f2plus.def_ice_cfg1
import f2plus.sct_create_joblist
import tools.readjoblist
addpath ./bin/

sctPath = './data/ice_cfg1/f2/sct/';
rfPath = './data/ice_cfg1/f2/rf/';

global PULSE_REPITITION_RATE SOUND_SPEED
PULSE_REPITITION_RATE = 1000;
SOUND_SPEED = 1540;

sct_uniform_flow(sctPath, [-0.01 0.01 -0.01 0.01 0.0001 0.05], 1, 5*1000^3, ...
    0.01, 1000);

joblist = sct_create_joblist(@run_calc_multi, @def_ice_cfg1, sctPath);
job = readjoblist(joblist);