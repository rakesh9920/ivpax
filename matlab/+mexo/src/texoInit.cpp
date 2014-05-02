#include "texo.h"
#include <mex.h>

bool newImage(void *, unsigned char *, int) {return true;}

void mexFunction(int nlhs, mxArray * plhs[],
int nrhs, const mxArray * prhs[]) { 

    // variable init
    int pci, usm, hv, channels, tx, szCine;
    char firmwarePath [50];
    TEXO_CALLBACK newImage;
    
    // read prhs
    mxGetString(prhs[0], firmwarePath, mxGetN(prhs[0])+ 1);
    pci = (int) mxGetScalar(prhs[1]);
    usm = (int) mxGetScalar(prhs[2]); 
    hv = (int) mxGetScalar(prhs[3]); 
    channels = (int) mxGetScalar(prhs[4]); 
    tx = (int) mxGetScalar(prhs[5]); 
    szCine = (int) mxGetScalar(prhs[6]); 
    
    texoSetCallback(newImage, 0);
    
    _vcaInfo vcaInfo;
    vcaInfo.amplification = 32;
    vcaInfo.activetermination = 4;
    vcaInfo.inclamp = 1600;
    vcaInfo.LPF = 1;
    vcaInfo.lnaIntegratorEnable = 1;
    vcaInfo.pgaIntegratorEnable = 1;
    vcaInfo.hpfDigitalEnable = 0;
    vcaInfo.hpfDigitalValue = 10;
    texoSetVCAInfo(vcaInfo);
    
	// create plhs
    bool suc = texoInit(firmwarePath, pci, usm, hv, channels, tx, szCine);
    plhs[0] = mxCreateLogicalScalar(suc); 
    
}
