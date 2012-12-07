#include "daq.h"
#include "daq_def.h"
#include <mex.h>

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 
    
    daqSequencePrms seq;
    daqRaylinePrms ray;
    
    seq.freeRun = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "freeRun")));
    seq.divisor = *((unsigned char *) mxGetData(mxGetProperty(prhs[0], 0, "divisor")));
    seq.hpfBypass = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "hpfBypass")));
    seq.externalTrigger = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "externalTrigger")));
    seq.externalClock = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "externalClock")));
    seq.fixedTGC = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "fixedTGC")));
    seq.fixedTGCLevel = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "fixedTGCLevel")));
    seq.lnaGain = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "lnaGain")));
    seq.pgaGain = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "pgaGain")));
    seq.biasCurrent = *((int *) mxGetData(mxGetProperty(prhs[0], 0, "biasCurrent")));   
    
    ray.channels = (unsigned int *) mxGetData(mxGetProperty(prhs[1], 0, "channels"));
    //ray.gainDelay = (int) mxGetProperty(prhs[1], 0, "gainDelay");
    //ray.gainOffset = (int) mxGetProperty(prhs[1], 0, "gainOffset");
    ray.lineDuration = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "lineDuration")));
    ray.numSamples = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "numSamples")));
    //ray.rxDelay = (int) mxGetProperty(prhs[1], 0, "rxDelay");
    ray.decimation = *((unsigned char *) mxGetData(mxGetProperty(prhs[1], 0, "decimation")));
    ray.sampling = *((unsigned char *) mxGetData(mxGetProperty(prhs[1], 0, "sampling")));

    // create plhs
    bool suc = daqRun(seq, ray);
    plhs[0] = mxCreateLogicalScalar(suc);
}
