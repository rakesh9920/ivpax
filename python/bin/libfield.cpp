//
// MATLAB Compiler: 5.0 (R2013b)
// Date: Thu May 29 17:09:28 2014
// Arguments: "-B" "macro_default" "-v" "-W" "cpplib:libfield" "-T" "link:lib"
// "-B" "functionlist.txt" "calc_scat" "calc_scat_multi" "calc_h" "calc_hhp"
// "calc_hp" "field_end" "field_init" "set_field" "xdc_2d_array" "xdc_concave"
// "xdc_excitation" "xdc_focus_times" "xdc_free" "xdc_get" "xdc_impulse"
// "xdc_linear_array" "xdc_piston" "xdc_rectangles" "xdc_quantization"
// "xdc_triangles" "xdc_convex_array" "xdc_convex_focused_array"
// "xdc_focused_array" 
//

#include <stdio.h>
#define EXPORTING_libfield 1
#include "libfield.h"

static HMCRINSTANCE _mcr_inst = NULL;


#if defined( _MSC_VER) || defined(__BORLANDC__) || defined(__WATCOMC__) || defined(__LCC__)
#ifdef __LCC__
#undef EXTERN_C
#endif
#include <windows.h>

static char path_to_dll[_MAX_PATH];

BOOL WINAPI DllMain(HINSTANCE hInstance, DWORD dwReason, void *pv)
{
    if (dwReason == DLL_PROCESS_ATTACH)
    {
        if (GetModuleFileName(hInstance, path_to_dll, _MAX_PATH) == 0)
            return FALSE;
    }
    else if (dwReason == DLL_PROCESS_DETACH)
    {
    }
    return TRUE;
}
#endif
#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultPrintHandler(const char *s)
{
  return mclWrite(1 /* stdout */, s, sizeof(char)*strlen(s));
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

#ifdef __cplusplus
extern "C" {
#endif

static int mclDefaultErrorHandler(const char *s)
{
  int written = 0;
  size_t len = 0;
  len = strlen(s);
  written = mclWrite(2 /* stderr */, s, sizeof(char)*len);
  if (len > 0 && s[ len-1 ] != '\n')
    written += mclWrite(2 /* stderr */, "\n", sizeof(char));
  return written;
}

#ifdef __cplusplus
} /* End extern "C" block */
#endif

/* This symbol is defined in shared libraries. Define it here
 * (to nothing) in case this isn't a shared library. 
 */
#ifndef LIB_libfield_C_API
#define LIB_libfield_C_API /* No special import/export declaration */
#endif

LIB_libfield_C_API 
bool MW_CALL_CONV libfieldInitializeWithHandlers(
    mclOutputHandlerFcn error_handler,
    mclOutputHandlerFcn print_handler)
{
    int bResult = 0;
  if (_mcr_inst != NULL)
    return true;
  if (!mclmcrInitialize())
    return false;
  if (!GetModuleFileName(GetModuleHandle("libfield"), path_to_dll, _MAX_PATH))
    return false;
    {
        mclCtfStream ctfStream = 
            mclGetEmbeddedCtfStream(path_to_dll);
        if (ctfStream) {
            bResult = mclInitializeComponentInstanceEmbedded(   &_mcr_inst,
                                                                error_handler, 
                                                                print_handler,
                                                                ctfStream);
            mclDestroyStream(ctfStream);
        } else {
            bResult = 0;
        }
    }  
    if (!bResult)
    return false;
  return true;
}

LIB_libfield_C_API 
bool MW_CALL_CONV libfieldInitialize(void)
{
  return libfieldInitializeWithHandlers(mclDefaultErrorHandler, mclDefaultPrintHandler);
}

LIB_libfield_C_API 
void MW_CALL_CONV libfieldTerminate(void)
{
  if (_mcr_inst != NULL)
    mclTerminateInstance(&_mcr_inst);
}

LIB_libfield_C_API 
void MW_CALL_CONV libfieldPrintStackTrace(void) 
{
  char** stackTrace;
  int stackDepth = mclGetStackTrace(&stackTrace);
  int i;
  for(i=0; i<stackDepth; i++)
  {
    mclWrite(2 /* stderr */, stackTrace[i], sizeof(char)*strlen(stackTrace[i]));
    mclWrite(2 /* stderr */, "\n", sizeof(char)*strlen("\n"));
  }
  mclFreeStackTrace(&stackTrace, stackDepth);
}


LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_scat(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "calc_scat", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_scat_multi(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "calc_scat_multi", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_h(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "calc_h", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_hhp(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "calc_hhp", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxCalc_hp(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "calc_hp", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxField_end(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "field_end", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxField_init(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "field_init", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxSet_field(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "set_field", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_2d_array(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_2d_array", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_concave(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_concave", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_excitation(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_excitation", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_focus_times(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_focus_times", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_free(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_free", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_get(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_get", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_impulse(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_impulse", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_linear_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_linear_array", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_piston(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_piston", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_rectangles(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_rectangles", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_quantization(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_quantization", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_triangles(int nlhs, mxArray *plhs[], int nrhs, mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_triangles", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_convex_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                      *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_convex_array", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_convex_focused_array(int nlhs, mxArray *plhs[], int nrhs, 
                                              mxArray *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_convex_focused_array", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_C_API 
bool MW_CALL_CONV mlxXdc_focused_array(int nlhs, mxArray *plhs[], int nrhs, mxArray 
                                       *prhs[])
{
  return mclFeval(_mcr_inst, "xdc_focused_array", nlhs, plhs, nrhs, prhs);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV calc_scat(int nargout, mwArray& scat, mwArray& start_time, const 
                            mwArray& Th1, const mwArray& Th2, const mwArray& points, 
                            const mwArray& amplitudes)
{
  mclcppMlfFeval(_mcr_inst, "calc_scat", nargout, 2, 4, &scat, &start_time, &Th1, &Th2, &points, &amplitudes);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV calc_scat_multi(int nargout, mwArray& scat, mwArray& start_time, const 
                                  mwArray& Th1, const mwArray& Th2, const mwArray& 
                                  points, const mwArray& amplitudes)
{
  mclcppMlfFeval(_mcr_inst, "calc_scat_multi", nargout, 2, 4, &scat, &start_time, &Th1, &Th2, &points, &amplitudes);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV calc_h(int nargout, mwArray& h, mwArray& start_time, const mwArray& Th, 
                         const mwArray& points)
{
  mclcppMlfFeval(_mcr_inst, "calc_h", nargout, 2, 2, &h, &start_time, &Th, &points);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV calc_hhp(int nargout, mwArray& hhp, mwArray& start_time, const mwArray& 
                           Th1, const mwArray& Th2, const mwArray& points)
{
  mclcppMlfFeval(_mcr_inst, "calc_hhp", nargout, 2, 3, &hhp, &start_time, &Th1, &Th2, &points);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV calc_hp(int nargout, mwArray& hp, mwArray& start_time, const mwArray& 
                          Th, const mwArray& points)
{
  mclcppMlfFeval(_mcr_inst, "calc_hp", nargout, 2, 2, &hp, &start_time, &Th, &points);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV field_end(int nargout, mwArray& res)
{
  mclcppMlfFeval(_mcr_inst, "field_end", nargout, 1, 0, &res);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV field_init(int nargout, mwArray& res, const mwArray& suppress)
{
  mclcppMlfFeval(_mcr_inst, "field_init", nargout, 1, 1, &res, &suppress);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV set_field(int nargout, mwArray& res, const mwArray& option_name, const 
                            mwArray& value)
{
  mclcppMlfFeval(_mcr_inst, "set_field", nargout, 1, 2, &res, &option_name, &value);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_2d_array(int nargout, mwArray& Th, const mwArray& no_ele_x, const 
                               mwArray& no_ele_y, const mwArray& width, const mwArray& 
                               height, const mwArray& kerf_x, const mwArray& kerf_y, 
                               const mwArray& enabled, const mwArray& no_sub_x, const 
                               mwArray& no_sub_y, const mwArray& focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_2d_array", nargout, 1, 10, &Th, &no_ele_x, &no_ele_y, &width, &height, &kerf_x, &kerf_y, &enabled, &no_sub_x, &no_sub_y, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_concave(int nargout, mwArray& Th, const mwArray& radius, const 
                              mwArray& focal_radius, const mwArray& ele_size)
{
  mclcppMlfFeval(_mcr_inst, "xdc_concave", nargout, 1, 3, &Th, &radius, &focal_radius, &ele_size);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_excitation(int nargout, mwArray& res, const mwArray& Th, const 
                                 mwArray& pulse)
{
  mclcppMlfFeval(_mcr_inst, "xdc_excitation", nargout, 1, 2, &res, &Th, &pulse);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_focus_times(int nargout, mwArray& res, const mwArray& Th, const 
                                  mwArray& times, const mwArray& delays)
{
  mclcppMlfFeval(_mcr_inst, "xdc_focus_times", nargout, 1, 3, &res, &Th, &times, &delays);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_free(int nargout, mwArray& res, const mwArray& Th)
{
  mclcppMlfFeval(_mcr_inst, "xdc_free", nargout, 1, 1, &res, &Th);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_get(int nargout, mwArray& data, const mwArray& Th, const mwArray& 
                          info_type)
{
  mclcppMlfFeval(_mcr_inst, "xdc_get", nargout, 1, 2, &data, &Th, &info_type);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_impulse(int nargout, mwArray& res, const mwArray& Th, const 
                              mwArray& pulse)
{
  mclcppMlfFeval(_mcr_inst, "xdc_impulse", nargout, 1, 2, &res, &Th, &pulse);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_linear_array(int nargout, mwArray& Th, const mwArray& no_elements, 
                                   const mwArray& width, const mwArray& height, const 
                                   mwArray& kerf, const mwArray& no_sub_x, const mwArray& 
                                   no_sub_y, const mwArray& focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_linear_array", nargout, 1, 7, &Th, &no_elements, &width, &height, &kerf, &no_sub_x, &no_sub_y, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_piston(int nargout, mwArray& Th, const mwArray& radius, const 
                             mwArray& ele_size)
{
  mclcppMlfFeval(_mcr_inst, "xdc_piston", nargout, 1, 2, &Th, &radius, &ele_size);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_rectangles(int nargout, mwArray& Th, const mwArray& rect, const 
                                 mwArray& center, const mwArray& focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_rectangles", nargout, 1, 3, &Th, &rect, &center, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_quantization(int nargout, mwArray& res, const mwArray& Th, const 
                                   mwArray& min_delay)
{
  mclcppMlfFeval(_mcr_inst, "xdc_quantization", nargout, 1, 2, &res, &Th, &min_delay);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_triangles(int nargout, mwArray& Th, const mwArray& data, const 
                                mwArray& center, const mwArray& focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_triangles", nargout, 1, 3, &Th, &data, &center, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_convex_array(int nargout, mwArray& Th, const mwArray& no_elements, 
                                   const mwArray& width, const mwArray& height, const 
                                   mwArray& kerf, const mwArray& Rconvex, const mwArray& 
                                   no_sub_x, const mwArray& no_sub_y, const mwArray& 
                                   focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_convex_array", nargout, 1, 8, &Th, &no_elements, &width, &height, &kerf, &Rconvex, &no_sub_x, &no_sub_y, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_convex_focused_array(int nargout, mwArray& Th, const mwArray& 
                                           no_elements, const mwArray& width, const 
                                           mwArray& height, const mwArray& kerf, const 
                                           mwArray& Rconvex, const mwArray& Rfocus, const 
                                           mwArray& no_sub_x, const mwArray& no_sub_y, 
                                           const mwArray& focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_convex_focused_array", nargout, 1, 9, &Th, &no_elements, &width, &height, &kerf, &Rconvex, &Rfocus, &no_sub_x, &no_sub_y, &focus);
}

LIB_libfield_CPP_API 
void MW_CALL_CONV xdc_focused_array(int nargout, mwArray& Th, const mwArray& no_elements, 
                                    const mwArray& width, const mwArray& height, const 
                                    mwArray& kerf, const mwArray& Rfocus, const mwArray& 
                                    no_sub_x, const mwArray& no_sub_y, const mwArray& 
                                    focus)
{
  mclcppMlfFeval(_mcr_inst, "xdc_focused_array", nargout, 1, 8, &Th, &no_elements, &width, &height, &kerf, &Rfocus, &no_sub_x, &no_sub_y, &focus);
}

