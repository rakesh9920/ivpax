
#include "matrix.h"

#ifndef _LIBF2_H_
#define _LIBF2_H_
        
struct ArrayInfo
{
    double * ptr;
    int nrows;
    int ncols;
    double t0;
};

// libf2 library methods
bool initialize();
bool initializeWithDiary(char *);
void shutdown();
void cleanup(double *);
mwArray convertToMwArray(ArrayInfo *);

// libf2 versions of Field II methods
void f2_field_init(int);
void f2_field_end();
void f2_set_field(char *, double);
int f2_xdc_piston(double, double);
void f2_xdc_excitation(int, ArrayInfo *);
void f2_xdc_impulse(int, ArrayInfo *);
void f2_xdc_focus_times(int, ArrayInfo *, ArrayInfo *);
struct ArrayInfo f2_xdc_get(int, char *);
int f2_xdc_rectangles(ArrayInfo *, ArrayInfo *, ArrayInfo *);
void f2_xdc_free(int);
int f2_xdc_2d_array(int, int, double, double, double, double, ArrayInfo *,
        int, int, ArrayInfo *);
int f2_xdc_linear_array(int, double, double, double, int, int, ArrayInfo *);
struct ArrayInfo f2_calc_scat(int, int, ArrayInfo *, ArrayInfo *);
struct ArrayInfo f2_calc_scat_multi(int, int, ArrayInfo *, ArrayInfo *);

#endif





