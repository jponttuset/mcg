// ------------------------------------------------------------------------ 
//  Copyright (C)
//  Universitat Politecnica de Catalunya BarcelonaTech (UPC) - Spain
//  University of California Berkeley (UCB) - USA
// 
//  Jordi Pont-Tuset <jordi.pont@upc.edu>
//  Pablo Arbelaez <arbelaez@berkeley.edu>
//  June 2014
// ------------------------------------------------------------------------ 
// This file is part of the MCG package presented in:
//    Arbelaez P, Pont-Tuset J, Barron J, Marques F, Malik J,
//    "Multiscale Combinatorial Grouping,"
//    Computer Vision and Pattern Recognition (CVPR) 2014.
// Please consider citing the paper if you use this code.
// ------------------------------------------------------------------------
#include "mex.h"
#include <set>
#include "matlab_multiarray.hpp"
using namespace std;

void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{    
    /* Check for proper number of arguments */
    if (nrhs != 3) { 
    	mexErrMsgTxt("Three input arguments required."); 
    } else if (nlhs > 4) {
        mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* Read blobs as cell of structs with fields rect and mask */
    size_t n_blobs = mxGetNumberOfElements(prhs[0]); 

    /* Rest of inputs as a Multiarray */
    ConstMatlabMultiArray<bool> valid_pixels(prhs[2]); /* Pixels to take into account */
    
    /* Input sizes and checks */
    size_t sx = valid_pixels.shape()[0];
    size_t sy = valid_pixels.shape()[1];

    /* Get the number of ground-truth objects */
    size_t n_objs = mxGetNumberOfElements(prhs[1]); 
    
    /* Allocate results */
    plhs[0] = mxCreateDoubleMatrix(1,n_blobs,mxREAL);
    MatlabMultiArray<double> out_areas(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(n_objs,n_blobs,mxREAL);
    MatlabMultiArray<double> out_int(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix(n_objs,n_blobs,mxREAL);
    MatlabMultiArray<double> out_fn(plhs[2]);
    
    /* Store all ground truth objects */
    std::vector<boost::multi_array<bool,2>> obj_mask(n_objs);
    for (std::size_t obj_id=0; obj_id<n_objs; ++obj_id)
    {    
        ConstMatlabMultiArray<bool> tmp(mxGetCell(prhs[1], obj_id));
        obj_mask[obj_id].resize(boost::extents[sx][sy]);
        for (std::size_t ii=0; ii<sx; ++ii)
            for (std::size_t jj=0; jj<sy; ++jj)
                obj_mask[obj_id][ii][jj] = tmp[ii][jj];
    }
                        
    /* Sweep all proposals */
    for(std::size_t kk=0; kk<n_blobs; ++kk)
    {
        const mxArray* cell_element_ptr = mxGetCell(prhs[0], kk);
        ConstMatlabMultiArray<double> rect(mxGetField(cell_element_ptr, 0, "rect"));
        std::size_t x_min = rect[0][0];
        std::size_t y_min = rect[0][1];
        std::size_t x_max = rect[0][2];
        std::size_t y_max = rect[0][3];

        ConstMatlabMultiArray<bool> curr_mask(mxGetField(cell_element_ptr, 0, "mask"));

        /* Sweep the mask of the object */
        for (std::size_t ii=0; ii<sx; ++ii)
        {
            for (std::size_t jj=0; jj<sy; ++jj)
            {
                /* Consider only valid pixels */
                if (valid_pixels[ii][jj])
                {
                    if ( (y_min-1<=jj) && (jj<y_max) && (x_min-1<=ii) && (ii<x_max) )
                    {
                        /* The mask is active --> Area and intersection */
                        if (curr_mask[ii-x_min+1][jj-y_min+1])
                        {
                            out_areas[0][kk]++;
                            
                            /* Sweep all annotated objects */
                            for (std::size_t obj_id=0; obj_id<n_objs; ++obj_id)
                                if (obj_mask[obj_id][ii][jj]>0)
                                    out_int[obj_id][kk]++;
                        }
                        else /* The mask is not active --> False negative */
                        {
                            /* Sweep all annotated objects */
                            for (std::size_t obj_id=0; obj_id<n_objs; ++obj_id)
                                if (obj_mask[obj_id][ii][jj]>0)
                                    out_fn[obj_id][kk]++;
                        }
                    }
                    else /* Out of the box --> False negative */
                    {
                        /* Sweep all annotated objects */
                        for (std::size_t obj_id=0; obj_id<n_objs; ++obj_id)
                            if (obj_mask[obj_id][ii][jj]>0)
                                out_fn[obj_id][kk]++;
                    }
                }
            }
        }
    }
}

