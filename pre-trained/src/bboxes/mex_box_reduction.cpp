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
#include "matlab_multiarray.hpp"
#include <iostream>
#include <list>
#include <set>
#include <algorithm>


int box_area(int up, int left, int down, int right)
{
   return (down-up+1)*(right-left+1);
}

int box_inters(int up1, int left1, int down1, int right1,
               int up2, int left2, int down2, int right2)
{
    int int_left  = std::max(left1,left2);
    int int_right = std::min(right1,right2);
    int int_up    = std::max(up1,up2);
    int int_down  = std::min(down1,down2);
    
    if ((int_left<=int_right) && (int_up<=int_down))
        return box_area(int_up, int_left, int_down, int_right);
    else
        return 0;
}


void mexFunction( int nlhs, mxArray *plhs[], 
        		  int nrhs, const mxArray*prhs[] )
{
    if(nrhs==0)
        mexErrMsgTxt("There should be at least 1 input parameters");
    
    /* Input parameters */
    ConstMatlabMultiArray<double> boxes(prhs[0]);
    ConstMatlabMultiArray<double> scores(prhs[1]);
    double J_th = 0.95;
    if (nrhs>2) J_th = mxGetScalar(prhs[2]);

    std::size_t n_boxes   = boxes.shape()[0];

    
    /* Scan all boxes */
    std::list<std::vector<int> > all_boxes;
    std::list<double>            all_scores;
    for (std::size_t ii=0; ii<n_boxes; ++ii)
    {
        bool found = 0;
        std::list<std::vector<int> >::iterator it = all_boxes.begin();
        
        /* Scan all deduplicated boxes */
        for (; it!=all_boxes.end(); ++it)
        {
            int curr_inters = box_inters((*it)[0], (*it)[1], (*it)[2], (*it)[3],
                                         boxes[ii][0], boxes[ii][1], boxes[ii][2], boxes[ii][3]);
            int area1 = box_area((*it)[0], (*it)[1], (*it)[2], (*it)[3]);
            int area2 = box_area(boxes[ii][0], boxes[ii][1], boxes[ii][2], boxes[ii][3]);
            
            double curr_J = (double)curr_inters/(double)(area1+area2-curr_inters);
            if (curr_J>=J_th)
            {
                found = true;
                break;
            }
        }
        
        if (!found)
        {
            std::vector<int> to_put;
            for (std::size_t kk=0; kk<boxes.shape()[1]; ++kk)
                to_put.push_back(boxes[ii][kk]);

            all_boxes.push_back(to_put);
            all_scores.push_back(scores[ii][0]);
        }
    }
    
    /* Allocate output boxes */
    std::size_t n_boxes_2 = all_boxes.size();
    plhs[0] = mxCreateDoubleMatrix(n_boxes_2,boxes.shape()[1],mxREAL);
    MatlabMultiArray<double> boxes2(plhs[0]);
    
    /* Fill boxes2 */
    std::size_t curr_pair = 0;
    std::list<std::vector<int> >::iterator list_it = all_boxes.begin();
    for (; list_it!=all_boxes.end(); ++list_it)
    {
        std::vector<int>::const_iterator vec_it2 = list_it->begin();
        std::size_t curr_reg = 0;
        for (; vec_it2!=list_it->end(); ++vec_it2)
        {
            boxes2[curr_pair][curr_reg] = *vec_it2;
            curr_reg++;
        }
        curr_pair++;
    } 
    
    /* Allocate output scores */
    plhs[1] = mxCreateDoubleMatrix(n_boxes_2,1,mxREAL);
    MatlabMultiArray<double> scores2(plhs[1]);
    
    /* Fill scores2 */
    std::size_t curr_score = 0;
    std::list<double>::iterator list_it_scores = all_scores.begin();
    for (; list_it_scores!=all_scores.end(); ++list_it_scores, ++curr_score)
        scores2[curr_score][0] = *list_it_scores;
}
