#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
    
    daqSequencePrms seq;
    daqRaylinePrms ray;
    
    seq.freeRun = *((int *) mxGetData(mxGetField(prhs[0], 0, "freeRun")));
    seq.divisor = *((unsigned char *) mxGetData(mxGetField(prhs[0], 0, "divisor")));
    seq.hpfBypass = *((int *) mxGetData(mxGetField(prhs[0], 0, "hpfBypass")));
    seq.externalTrigger = *((int *) mxGetData(mxGetField(prhs[0], 0, "externalTrigger")));
    seq.externalClock = *((int *) mxGetData(mxGetField(prhs[0], 0, "externalClock")));
    seq.fixedTGC = *((int *) mxGetData(mxGetField(prhs[0], 0, "fixedTGC")));
    seq.fixedTGCLevel = *((int *) mxGetData(mxGetField(prhs[0], 0, "fixedTGCLevel")));
    seq.lnaGain = *((int *) mxGetData(mxGetField(prhs[0], 0, "lnaGain")));
    seq.pgaGain = *((int *) mxGetData(mxGetField(prhs[0], 0, "pgaGain")));
    seq.biasCurrent = *((int *) mxGetData(mxGetField(prhs[0], 0, "biasCurrent")));   
    
    ray.channels = (unsigned int *) mxGetData(mxGetField(prhs[1], 0, "channels"));
    //ray.gainDelay = (int) mxGetField(prhs[1], 0, "gainDelay");
    //ray.gainOffset = (int) mxGetField(prhs[1], 0, "gainOffset");
    ray.lineDuration = *((int *) mxGetData(mxGetField(prhs[1], 0, "lineDuration")));
    ray.numSamples = *((int *) mxGetData(mxGetField(prhs[1], 0, "numSamples")));
    //ray.rxDelay = (int) mxGetField(prhs[1], 0, "rxDelay");
    ray.decimation = *((unsigned char *) mxGetData(mxGetField(prhs[1], 0, "decimation")));
    ray.sampling = *((unsigned char *) mxGetData(mxGetField(prhs[1], 0, "sampling")));

    // create plhs
    bool suc = daqRun(seq, ray);
    plhs[0] = mxCreateLogicalScalar(suc);
}
