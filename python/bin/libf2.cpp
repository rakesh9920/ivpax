
#include "libfield.h"
#include "libf2.h"
//#include "matrix.h"
#include <stdio.h>
#include <iostream>
#include <fstream>

int initialize()
{
    if (!mclInitializeApplication(NULL, 0))
    {
        std::cout << "libf2: Failed to initialize library\n";
        std::cout.flush();
        return 0;
    }
    
    if (!libfieldInitialize())
    {
        std::cout << "libf2: Failed to initialize library\n";
        std::cout.flush();
        return 0;
    }
    
    std::cout << "libf2: library initialized\n";
    std::cout.flush();
    return 1;
}

int initializeWithDiary(char * filePath)
{
    freopen(filePath, "w", stdout);
    return initialize();
}

void shutdownlib()
{
    libfieldTerminate();
    mclTerminateApplication();
    std::cout << "libf2: library terminated\n";
    std::cout.flush();
    fclose(stdout);
}

mwArray convertToMwArray(ArrayInfo * array)
{
    int nrows = array->nrows;
    int ncols = array->ncols;
    
    mwArray mw ((mwSize) nrows, (mwSize) ncols, mxDOUBLE_CLASS, mxREAL);
    mw.SetData(array->ptr, nrows*ncols);
    
    return mw;
}

void f2_field_init(int suppress_)
{
    mwArray suppress (suppress_);
    mwArray res;
    
    field_init(0, res, suppress);
    std::cout.flush();
}

void f2_field_end()
{
    mwArray res;
    
    field_end(0, res);
    std::cout.flush();
}

void f2_set_field(char * opt_, double val_)
{
    mwArray opt (opt_);
    mwArray val (val_);
    mwArray res;
    
    set_field(0, res, opt, val);
    
    std::cout << "Field II: " << opt_ << " set to " << val_ << "\n"; 
    std::cout.flush();
}

int f2_xdc_piston(double radius_, double elSize_)
{
    mwArray radius (radius_);
    mwArray elSize (elSize_);
    mwArray res;
    
    xdc_piston(1, res, radius, elSize);
    
    std::cout << "Field II: piston array defined\n"; 
    std::cout.flush();
    return (int) res.Get(1,1,1);
}

void f2_xdc_excitation(int Th_, ArrayInfo * exc_)
{
    // initialize mwArrays
    mwArray Th (Th_);
    int nrows = exc_->nrows;
    int ncols = exc_->ncols;
    mwArray exc ((mwSize) nrows, (mwSize) ncols, mxDOUBLE_CLASS,
            mxREAL);
    mwArray res;
    
    // set mwArray data
    exc.SetData(exc_->ptr, nrows*ncols);
    
    // call function
    xdc_excitation(0, res, Th, exc);
    
    // output status to diary
    std::cout << "Field II: excitation set\n";
    std::cout.flush();
}

void f2_xdc_impulse(int Th_, ArrayInfo * imp_)
{
    // initialize mwArrays
    mwArray Th (Th_);
    int nrows = imp_->nrows;
    int ncols = imp_->ncols;
    mwArray imp ((mwSize) nrows, (mwSize) ncols, mxDOUBLE_CLASS,
            mxREAL);
    mwArray res;
    
    // set mwArray data
    imp.SetData(imp_->ptr, nrows*ncols);
    
    // call function
    xdc_impulse(0, res, Th, imp);
    
    std::cout << "Field II: impulse set\n";
    std::cout.flush();
}

void f2_xdc_focus_times(int Th_, ArrayInfo * times_, ArrayInfo * delays_)
{
    mwArray Th (Th_);
    int nrows1 = times_->nrows;
    int ncols1 = times_->ncols;
    int nrows2 = delays_->nrows;
    int ncols2 = delays_->ncols;
    mwArray times ((mwSize) nrows1, (mwSize) ncols1, mxDOUBLE_CLASS, mxREAL);
    mwArray delays ((mwSize) nrows2, (mwSize) ncols2, mxDOUBLE_CLASS, mxREAL);
    mwArray res;
    
    times.SetData(times_->ptr, nrows1*ncols1);
    delays.SetData(delays_->ptr, nrows2*ncols2);
    
    xdc_focus_times(0, res, Th, times, delays);
    
    std::cout << "Field II: focus times set\n";
    std::cout.flush();
}
void f2_xdc_apodization(int Th_, ArrayInfo * times_, ArrayInfo * apod_)
{
    mwArray Th (Th_);
    mwArray times = convertToMwArray(times_);
    mwArray apod = convertToMwArray(apod_);
    mwArray res;
    
    xdc_apodization(0, res, Th, times, apod); 
}

void f2_xdc_free(int Th_)
{
    mwArray Th (Th_);
    mwArray res;
    
    xdc_free(0, res, Th);
}

struct ArrayInfo f2_calc_scat(int Th1_, int Th2_, ArrayInfo * points_, 
        ArrayInfo * amplitudes_)
{
    // initialize mwArrays
    mwArray Th1 (Th1_);
    mwArray Th2 (Th2_);
    int nrows1, ncols1, nrows2, ncols2;
    nrows1 = points_->nrows;
    ncols1 = points_->ncols;
    nrows2 = amplitudes_->nrows;
    ncols2 = amplitudes_->ncols;
    mwArray points ((mwSize) nrows1, (mwSize) ncols1, mxDOUBLE_CLASS, mxREAL);
    mwArray amplitudes ((mwSize) nrows2, (mwSize) ncols2, mxDOUBLE_CLASS, mxREAL);
    mwArray res1, res2;
    
    // set mwArray data
    points.SetData(points_->ptr, nrows1*ncols1);
    amplitudes.SetData(amplitudes_->ptr, nrows2*ncols2);
    
    // call function
    calc_scat(2, res1, res2, Th1, Th2, points, amplitudes);
    
    // initialize c data
    ArrayInfo scat;
    
    //arrShape scatShape;
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);
    
    // output status to diary
    std::cout << "Field II: calc_scat called successfully\n";
    std::cout << scat.nrows << " " << scat.ncols << "\n";
    std::cout.flush();
    
    return scat;
}
struct ArrayInfo f2_calc_h(double Th_, ArrayInfo * points_)
{
    // initialize mwArrays
    mwArray Th (Th_);
    mwArray points = convertToMwArray(points_);
    mwArray res1, res2;
    
    // call function
    calc_h(2, res1, res2, Th, points);
    
    // initialize c data
    ArrayInfo scat;
    
    //arrShape scatShape;
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);

    return scat;    
}

struct ArrayInfo f2_calc_hhp(double Th1_, double Th2_ , ArrayInfo * points_)
{
    // initialize mwArrays
    mwArray Th1 (Th1_);
    mwArray Th2 (Th2_);
    mwArray points = convertToMwArray(points_);
    mwArray res1, res2;
    
    // call function
    calc_hhp(2, res1, res2, Th1, Th2, points);
    
    // initialize c data
    ArrayInfo scat;
    
    //arrShape scatShape;
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);

    return scat;      
}
struct ArrayInfo f2_calc_hp(double Th_, ArrayInfo * points_)
{    
    // initialize mwArrays
    mwArray Th (Th_);
    mwArray points = convertToMwArray(points_);
    mwArray res1, res2;
    
    // call function
    calc_hp(2, res1, res2, Th, points);
    
    // initialize c data
    ArrayInfo scat;
    
    //arrShape scatShape;
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);

    return scat;    
}

struct ArrayInfo f2_calc_scat_multi(int Th1_, int Th2_, ArrayInfo * points_, 
        ArrayInfo * amplitudes_)
{
    // initialize mwArrays
    mwArray Th1 (Th1_);
    mwArray Th2 (Th2_);
    int nrows1, ncols1, nrows2, ncols2;
    nrows1 = points_->nrows;
    ncols1 = points_->ncols;
    nrows2 = amplitudes_->nrows;
    ncols2 = amplitudes_->ncols;
    mwArray points ((mwSize) nrows1, (mwSize) ncols1, mxDOUBLE_CLASS, mxREAL);
    mwArray amplitudes ((mwSize) nrows2, (mwSize) ncols2, mxDOUBLE_CLASS, mxREAL);
    mwArray res1, res2;
    
    // set mwArray data
    points.SetData(points_->ptr, nrows1*ncols1);
    amplitudes.SetData(amplitudes_->ptr, nrows2*ncols2);
    
    // call function
    calc_scat_multi(2, res1, res2, Th1, Th2, points, amplitudes);
    
    // initialize c data
    ArrayInfo scat;
    
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);
    
    // output status to diary
    std::cout << "Field II: calc_scat called successfully\n";
    std::cout << scat.nrows << " " << scat.ncols << "\n";
    std::cout.flush();
    
    return scat;
}

struct ArrayInfo f2_calc_scat_all(int Th1_, int Th2_, ArrayInfo * points_, 
        ArrayInfo * amplitudes_, int dec_)
{
    // initialize mwArrays
    mwArray Th1 (Th1_);
    mwArray Th2 (Th2_);
    mwArray points = convertToMwArray(points_);
    mwArray amplitudes = convertToMwArray(amplitudes_);
    mwArray dec (dec_);
    mwArray res1, res2;
    
    // call function
    calc_scat_all(2, res1, res2, Th1, Th2, points, amplitudes, dec);
    
    // initialize c data
    ArrayInfo scat;
    
    //arrShape scatShape;
    mwArray dims = res1.GetDimensions();
    scat.nrows = (int) dims.Get(2,1,1);
    scat.ncols = (int) dims.Get(2,1,2);
    scat.ptr = new double [scat.nrows*scat.ncols];
    
    // get results from mwArrays
    res1.GetData(scat.ptr, scat.nrows*scat.ncols);
    scat.t0 = (double) res2.Get(1,1,1);

    return scat;       
}

int f2_xdc_2d_array(int nelex_, int neley_, double width_, double height_, 
        double kerfx_, double kerfy_, ArrayInfo * enabled_,
        int nsubx_, int nsuby_, ArrayInfo * focus_)
{
    mwArray nelex (nelex_);
    mwArray neley (neley_);
    mwArray width (width_);
    mwArray height (height_);
    mwArray kerfx (kerfx_);
    mwArray kerfy (kerfy_); 
    mwArray nsubx (nsubx_);
    mwArray nsuby (nsuby_);
    mwArray enabled = convertToMwArray(enabled_);
    mwArray focus = convertToMwArray(focus_);
    mwArray res;
    
    xdc_2d_array(1, res, nelex, neley, width, height, kerfx, kerfy, enabled, nsubx,
            nsuby, focus);
    
    return (int) res.Get(1,1);
}

int f2_xdc_concave(double radius_, double focus_, double elsize_)
{
    mwArray radius (radius_);
    mwArray focus (focus_);
    mwArray elsize (elsize_);
    mwArray res;
    
    xdc_concave(1, res, radius, focus, elsize);
    
    return (int) res.Get(1,1);
}

struct ArrayInfo f2_xdc_get(double Th_, char * opt_)
{
    mwArray Th (Th_); //Th_ must be a double! call fails if int
    mwArray opt (opt_);
    mwArray res;
    
    xdc_get(1, res, Th, opt);
    
    // copy to c memory and get array info
    ArrayInfo data;
    
    mwArray dims = res.GetDimensions();
    data.nrows = (int) dims.Get(2,1,1);
    data.ncols = (int) dims.Get(2,1,2);
    
    std::cout << data.nrows << " " << data.ncols << "\n";
    std::cout.flush();
    
    data.ptr = new double [data.nrows*data.ncols];
    res.GetData(data.ptr, data.nrows*data.ncols);
    
    data.t0 = 0;
    
    return data;
}

// struct ArrayInfo f2_xdc_get_rect()
// {
//     mwArray Th (0);
//     mwArray res;
//     
//     xdc_get_rect(1, res, Th);
//     
//     ArrayInfo data;
//     
//     mwArray dims = res.GetDimensions();
//     data.nrows = (int) dims.Get(2,1,1);
//     data.ncols = (int) dims.Get(2,1,2);
//     
//     data.ptr = new double [data.nrows*data.ncols];
//     res.GetData(data.ptr, data.nrows*data.ncols);
//     
//     data.t0 = 0;
//     
//     return data;
// }

int f2_xdc_rectangles(ArrayInfo * rect_, ArrayInfo * center_, ArrayInfo * focus_)
{
    mwArray rect = convertToMwArray(rect_);
    mwArray center = convertToMwArray(center_);
    mwArray focus = convertToMwArray(focus_);
    mwArray res;
    
    xdc_rectangles(1, res, rect, center, focus);
    
    return (int) res.Get(1,1,1);
}

int f2_xdc_linear_array(int nele_, double width_, double height_, double kerf_, 
        int nsubx_, int nsuby_, ArrayInfo * focus_)
{
    mwArray nele (nele_);
    mwArray width (width_);
    mwArray height (height_);
    mwArray kerf (kerf_);
    mwArray nsubx (nsubx_);
    mwArray nsuby (nsuby_);
    mwArray focus = convertToMwArray(focus_);
    mwArray res;
    
    xdc_linear_array(1, res, nele, width, height, kerf, nsubx, nsuby, focus);
    
    return (int) res.Get(1,1,1);
}

int f2_xdc_focused_array(int nele_, double width_, double height_, double kerf_, 
        double rfocus_, int nsubx_, int nsuby_, ArrayInfo * focus_)
{
    mwArray nele (nele_);
    mwArray width (width_);
    mwArray height (height_);
    mwArray kerf (kerf_);
    mwArray rfocus (rfocus_);
    mwArray nsubx (nsubx_);
    mwArray nsuby (nsuby_);
    int nrows = focus_->nrows;
    int ncols = focus_->ncols;
    mwArray focus ((mwSize) nrows, (mwSize) ncols, mxDOUBLE_CLASS, mxREAL);
    focus.SetData(focus_->ptr, nrows*ncols);
    mwArray res;
    
    xdc_focused_array(1, res, nele, width, height, kerf, rfocus, nsubx, nsuby, 
            focus);
    
    return (int) res.Get(1,1,1);  
}

void cleanup(double * array) {
    delete [] array;
}

int main() {}