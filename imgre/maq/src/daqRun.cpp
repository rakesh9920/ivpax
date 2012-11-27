#include "daq.h"
#include "daq_def.h"
#include <mex.h>
#include "stdint.h"

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
    
    daqSequencePrms seq;
    daqRaylinePrms ray;
    
    seq.freeRun = (int) mxGetField(prhs[0], 0, "freeRun");
    seq.divisor = (unsigned char) mxGetField(prhs[0], 0, "divisor");
    seq.hpfBypass = (int) mxGetField(prhs[0], 0, "hpfBypass");
    seq.externalTrigger = (int) mxGetField(prhs[0], 0, "externalTrigger");
    seq.externalClock = (int) mxGetField(prhs[0], 0, "externalClock");
    seq.fixedTGC = (int) mxGetField(prhs[0], 0, "fixedTGC");
    seq.fixedTGCLevel = (int) mxGetField(prhs[0], 0, "fixedTGCLevel");
    seq.lnaGain = (int) mxGetField(prhs[0], 0, "lnaGain");
    seq.pgaGain = (int) mxGetField(prhs[0], 0, "pgaGain");
    seq.biasCurrent = (int) mxGetField(prhs[0], 0, "biasCurrent");   
    
    ray.channels = (unsigned int *) mxGetField(prhs[1], 1, "channels");
    ray.gainDelay = (int) mxGetField(prhs[1], 1, "gainDelay");
    ray.gainOffset = (int) mxGetField(prhs[1], 1, "gainOffset");
    ray.lineDuration = (int) mxGetField(prhs[1], 1, "lineDuration");
    ray.numSamples = (int) mxGetField(prhs[1], 1, "numSamples");
    ray.rxDelay = (int) mxGetField(prhs[1], 1, "rxDelay");
    ray.decimation = (unsigned char) mxGetField(prhs[1], 1, "decimation");
    ray.sampling = (unsigned char) mxGetField(prhs[1], 1, "sampling");
}
