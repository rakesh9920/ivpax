//
// MATLAB Compiler: 5.0 (R2013b)
// Date: Thu May 29 14:20:19 2014
// Arguments: "-B" "macro_default" "-v" "-W" "cpplib:libfield" "-T" "link:lib"
// "-B" "functionlist.txt" "calc_scat" "calc_scat_multi" "field_end"
// "field_init" "set_field" "xdc_2d_array" "xdc_concave" "xdc_excitation"
// "xdc_focus_times" "xdc_free" "xdc_get" "xdc_impulse" "xdc_linear_array"
// "xdc_piston" "xdc_rectangles" "xdc_quantization" "xdc_triangles"
// "xdc_convex_array" "xdc_convex_focused_array" "xdc_focused_array" 
//

#ifndef __libfield_h
#define __libfield_h 1

#if defined(__cplusplus) && !defined(mclmcrrt_h) && defined(__linux__)
#  pragma implementation "mclmcrrt.h"
#endif
#include "mclmcrrt.h"
#include "mclcppclass.h"
#ifdef __cplusplus
extern "C" {
#endif

#if defined(__SUNPRO_CC)
/* Solaris shared libraries use __global, rather than mapfiles
 * to define the API exported from a shared library. __global is
 * only necessary when building the library -- files including
 * this header file to use the library do not need the __global
 * declaration; hence the EXPORTING_<library> logic.
 */

#ifdef EXPORTING_libfield
#define PUBLIC_libfield_C_API __global
#else
#define PUBLIC_libfield_C_API /* No import statement needed. */
#endif

#define LIB_libfield_C_API PUBLIC_libfield_C_API

#elif defined(_HPUX_SOURCE)

#ifdef EXPORTING_libfield
#define PUBLIC_libfield_C_API __declspec(dllexport)
#else
#define PUBLIC_libfield_C_API __declspec(dllimport)
#endif

#define LIB_libfield_C_API PUBLIC_libfield_C_API


#else

#define LIB_libfield_C_API

#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libfield_C_API 
#define LIB_libfield_C_API /* No special import/export declaration */
#endif

extern LIB_libfield_C_API 
bool MW_CALL_CONV libfieldInitializeWithHandlers(
       mclOutputHandlerFcn error_handler, 
       mclOutputHandlerFcn print_handler);

extern LIB_libfield_C_API 
bool MW_CALL_CONV libfieldInitialize(void);

extern LIB_libfield_C_API 
void MW_CALL_CONV libfieldTerminate(void);



extern LIB_libfield_C_API 
void MW_CALL_CONV libfieldPrintStackTrace(void);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_scat(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_scat_multi(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                     *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxField_end(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxField_init(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxSet_field(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_2d_array(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_concave(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_excitation(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_focus_times(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                     *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_free(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_get(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_impulse(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_linear_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_piston(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_rectangles(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_quantization(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_triangles(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_convex_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_convex_focused_array(int nlhs, mxArray *plhs[], int nrhs, 
                                              mxArray *prhs[]);

extern LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_focused_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                       *prhs[]);


#ifdef __cplusplus
}
#endif

#ifdef __cplusplus

/* On Windows, use __declspec to control the exported API */
#if defined(_MSC_VER) || defined(__BORLANDC__)

#ifdef EXPORTING_libfield
#define PUBLIC_libfield_CPP_API __declspec(dllexport)
#else
#define PUBLIC_libfield_CPP_API __declspec(dllimport)
#endif

#define LIB_libfield_CPP_API PUBLIC_libfield_CPP_API

#else

#if !defined(LIB_libfield_CPP_API)
#if defined(LIB_libfield_C_API)
#define LIB_libfield_CPP_API LIB_libfield_C_API
#else
#define LIB_libfield_CPP_API /* empty! */ 
#endif
#endif

#endif

extern LIB_libfield_CPP_API void MW_CALL_CONV calc_scat(int nargout, mwArray& scat, mwArray& start_time, const mwArray& Th1, const mwArray& Th2, const mwArray& points, const mwArray& amplitudes);

extern LIB_libfield_CPP_API void MW_CALL_CONV calc_scat_multi(int nargout, mwArray& scat, mwArray& start_time, const mwArray& Th1, const mwArray& Th2, const mwArray& points, const mwArray& amplitudes);

extern LIB_libfield_CPP_API void MW_CALL_CONV field_end(int nargout, mwArray& res);

extern LIB_libfield_CPP_API void MW_CALL_CONV field_init(int nargout, mwArray& res, const mwArray& suppress);

extern LIB_libfield_CPP_API void MW_CALL_CONV set_field(int nargout, mwArray& res, const mwArray& option_name, const mwArray& value);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_2d_array(int nargout, mwArray& Th, const mwArray& no_ele_x, const mwArray& no_ele_y, const mwArray& width, const mwArray& height, const mwArray& kerf_x, const mwArray& kerf_y, const mwArray& enabled, const mwArray& no_sub_x, const mwArray& no_sub_y, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_concave(int nargout, mwArray& Th, const mwArray& radius, const mwArray& focal_radius, const mwArray& ele_size);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_excitation(int nargout, mwArray& res, const mwArray& Th, const mwArray& pulse);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_focus_times(int nargout, mwArray& res, const mwArray& Th, const mwArray& times, const mwArray& delays);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_free(int nargout, mwArray& res, const mwArray& Th);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_get(int nargout, mwArray& data, const mwArray& Th, const mwArray& info_type);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_impulse(int nargout, mwArray& res, const mwArray& Th, const mwArray& pulse);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_linear_array(int nargout, mwArray& Th, const mwArray& no_elements, const mwArray& width, const mwArray& height, const mwArray& kerf, const mwArray& no_sub_x, const mwArray& no_sub_y, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_piston(int nargout, mwArray& Th, const mwArray& radius, const mwArray& ele_size);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_rectangles(int nargout, mwArray& Th, const mwArray& rect, const mwArray& center, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_quantization(int nargout, mwArray& res, const mwArray& Th, const mwArray& min_delay);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_triangles(int nargout, mwArray& Th, const mwArray& data, const mwArray& center, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_convex_array(int nargout, mwArray& Th, const mwArray& no_elements, const mwArray& width, const mwArray& height, const mwArray& kerf, const mwArray& Rconvex, const mwArray& no_sub_x, const mwArray& no_sub_y, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_convex_focused_array(int nargout, mwArray& Th, const mwArray& no_elements, const mwArray& width, const mwArray& height, const mwArray& kerf, const mwArray& Rconvex, const mwArray& Rfocus, const mwArray& no_sub_x, const mwArray& no_sub_y, const mwArray& focus);

extern LIB_libfield_CPP_API void MW_CALL_CONV xdc_focused_array(int nargout, mwArray& Th, const mwArray& no_elements, const mwArray& width, const mwArray& height, const mwArray& kerf, const mwArray& Rfocus, const mwArray& no_sub_x, const mwArray& no_sub_y, const mwArray& focus);

#endif
#endif
