
#include "matrix.h"

#ifndef _LIBF2_H_
#define _LIBF2_H_

extern "C" 
{
    
struct ArrayInfo
{
    double * ptr;
    int nrows;
    int ncols;
    double t0;
};

// libf2 library methods
int initialize();
int initializeWithDiary(char *);
void shutdownlib();
void cleanup(double *);

// libf2 versions of Field II methods
void f2_field_init(int);
void f2_field_end();
void f2_set_field(char *, double);
int f2_xdc_piston(double, double);
void f2_xdc_excitation(int, ArrayInfo *);
void f2_xdc_impulse(int, ArrayInfo *);
void f2_xdc_focus_times(int, ArrayInfo *, ArrayInfo *);
struct ArrayInfo f2_xdc_get(double, char *);
// struct ArrayInfo f2_xdc_get_rect();
int f2_xdc_rectangles(ArrayInfo *, ArrayInfo *, ArrayInfo *);
void f2_xdc_free(int);
int f2_xdc_2d_array(int, int, double, double, double, double, ArrayInfo *,
        int, int, ArrayInfo *);
int f2_xdc_linear_array(int, double, double, double, int, int, ArrayInfo *);
int f2_xdc_concave(double, double, double);
int f2_xdc_focused_array(int, double, double, double, double, int, int, ArrayInfo *);
// double f2_xdc_focused_array(double, double, double, double, double, double, double, ArrayInfo *);
struct ArrayInfo f2_calc_scat(int, int, ArrayInfo *, ArrayInfo *);
struct ArrayInfo f2_calc_scat_multi(int, int, ArrayInfo *, ArrayInfo *);
struct ArrayInfo f2_calc_h(double, ArrayInfo *);
struct ArrayInfo f2_calc_hhp(double, double, ArrayInfo *);
struct ArrayInfo f2_calc_hp(double, ArrayInfo *);
struct ArrayInfo f2_calc_scat_all(int, int, ArrayInfo *, ArrayInfo *, int);
}

mwArray convertToMwArray(ArrayInfo *);
#endif





