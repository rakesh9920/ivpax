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
    ray.gainDelay = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "gainDelay")));
    ray.gainOffset = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "gainOffset")));
    ray.lineDuration = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "lineDuration")));
    ray.numSamples = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "numSamples")));
    ray.rxDelay = *((int *) mxGetData(mxGetProperty(prhs[1], 0, "rxDelay")));
    ray.decimation = *((unsigned char *) mxGetData(mxGetProperty(prhs[1], 0, "decimation")));
    ray.sampling = *((unsigned char *) mxGetData(mxGetProperty(prhs[1], 0, "sampling")));
    
    #ifdef MEX_OUTPUT_CHECK
        mexPrintf("freeRun = %d\n", seq.freeRun);
        mexPrintf("divisor = %u\n", seq.divisor);
        mexPrintf("hpfBypass = %d\n", seq.hpfBypass);
        mexPrintf("externalTrigger = %d\n", seq.externalTrigger);
        mexPrintf("externalClock = %d\n", seq.externalClock);
        mexPrintf("fixedTGC = %d\n", seq.fixedTGC);
        mexPrintf("fixedTGCLevel = %d\n", seq.fixedTGCLevel);
        mexPrintf("lnaGain = %d\n", seq.lnaGain);
        mexPrintf("pgaGain = %d\n", seq.pgaGain);
        mexPrintf("biasCurrent = %d\n", seq.biasCurrent);
        
        mexPrintf("channels = %d %d %d %d\n", ray.channels[0], ray.channels[1], ray.channels[2], ray.channels[3]);
        mexPrintf("gainDelay = %d\n", ray.gainDelay);
        mexPrintf("gainOffset = %d\n", ray.gainOffset);
        mexPrintf("lineDuration = %d\n", ray.lineDuration);
        mexPrintf("numSamples = %d\n", ray.numSamples);
        mexPrintf("rxDelay = %d\n", ray.rxDelay);
        mexPrintf("decimation = %u\n", ray.decimation);
        mexPrintf("sampling = %u\n", ray.sampling);
    #endif

    // create plhs
    bool suc = daqRun(seq, ray);
    plhs[0] = mxCreateLogicalScalar(suc);
}
