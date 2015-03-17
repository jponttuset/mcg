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

void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{    
    /* Check for proper number of arguments */
    if (nrhs != 3) { 
    	mexErrMsgTxt("Three input arguments required."); 
    } else if (nlhs > 4) {
        mexErrMsgTxt("Too many output arguments."); 
    } 
    
    /* Input as a Multiarray */
    ConstMatlabMultiArray3<bool>                masks(prhs[0]); /* Object masks */
    ConstMatlabMultiArray<bool>          valid_pixels(prhs[2]); /* Pixels to take into account */
    
    /* Input sizes and checks */
    size_t sx = masks.shape()[0];
    size_t sy = masks.shape()[1];
    size_t n_masks = masks.shape()[2];
    
    /* Get the number of ground-truth objects */
    size_t n_objs = mxGetNumberOfElements(prhs[1]); 

    /* Allocate results */
    plhs[0] = mxCreateDoubleMatrix(1,n_masks,mxREAL);
    MatlabMultiArray<double> out_areas(plhs[0]);
    plhs[1] = mxCreateDoubleMatrix(n_objs,n_masks,mxREAL);
    MatlabMultiArray<double> out_int(plhs[1]);
    plhs[2] = mxCreateDoubleMatrix(n_objs,n_masks,mxREAL);
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
    

    /* Sweep the mask of the object */
    for (std::size_t ii=0; ii<sx; ++ii)
    {
        for (std::size_t jj=0; jj<sy; ++jj)
        {
            /* Consider only valid pixels */
            if (valid_pixels[ii][jj]) 
            {
                /* Sweep all proposals */
                for(std::size_t kk=0; kk<n_masks; ++kk)
                {
                    if (masks[ii][jj][kk])
                    {
                        out_areas[0][kk]++;

                        /* Sweep all annotated objects */
                        for (std::size_t obj_id=0; obj_id<n_objs; ++obj_id)
                            if (obj_mask[obj_id][ii][jj]>0)
                                out_int[obj_id][kk]++;
                    }
                    else
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
