// (fluid_rho,fluid_c,w0,k0,nodes_S,R,alpha0)



#include <cmath>
#include <iostream>
#include <mex.h>
#include <complex>


using namespace std;



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    double fluid_rho=((double *)mxGetData(prhs[0]))[0];
    double fluid_c=((double *)mxGetData(prhs[1]))[0];
    double w0=((double *)mxGetData(prhs[2]))[0];
    double k0=((double *)mxGetData(prhs[3]))[0];
    
    #define nodes_S prhs[4]
    #define R prhs[5]
    
    
    double alpha0=((double *)mxGetData(prhs[6]))[0];
    
     #define Z plhs[0]

    if (nrhs!=7)
        mexErrMsgTxt("Wrong number of input arguments!");
    
    double *nodes_S_p=(double *)mxGetData(nodes_S);
            
    double *R_p=(double *)mxGetData(R);
     
    int numel_R_rows=mxGetM(R); 
    int numel_R_cols=mxGetN(R); 
    
    
    
    Z=mxCreateNumericMatrix(mxGetM(R), mxGetN(R), mxDOUBLE_CLASS, mxCOMPLEX); /* Create an empty array */

    double *Zr_p=(double *)mxGetPr(Z);
    double *Zi_p=(double *)mxGetPi(Z);


    const double pi = 3.141592653589793;

    double r_ref;

    complex<double> i(0,1);

     complex<double> z;

     double a_eq;


    for (int ind=0; ind<numel_R_rows; ind++)
    { 
         for (int ind2=0; ind2<=ind; ind2++)
        {   
       
            if (R_p[ind+ind2*numel_R_rows]>0)         
                z=i*fluid_rho*w0*nodes_S_p[ind]/2.0/pi*exp(-i*k0*R_p[ind+ind2*numel_R_rows])/R_p[ind+ind2*numel_R_rows]*pow(10,-1*alpha0/20*R_p[ind+ind2*numel_R_rows]);
            else
            {
                a_eq=sqrt(nodes_S_p[ind]/pi);
                z=fluid_rho*fluid_c*(0.5*pow(k0*a_eq,2) + i*8.0/3.0/pi*k0*a_eq);
            }
            
          
            Zr_p[ind+ind2*numel_R_rows]=real(z);
            Zi_p[ind+ind2*numel_R_rows]=imag(z);
            
            Zr_p[ind2+ind*numel_R_rows]=real(z);
            Zi_p[ind2+ind*numel_R_rows]=imag(z);
   
         }
         
         
         
  }


  
}