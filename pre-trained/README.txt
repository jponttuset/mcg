% ------------------------------------------------------------------------ 
%  Copyright (C)
%  Universitat Politecnica de Catalunya BarcelonaTech (UPC) - Spain
%  University of California Berkeley (UCB) - USA
% 
%  Jordi Pont-Tuset <jordi.pont@upc.edu>
%  Pablo Arbelaez <arbelaez@berkeley.edu>
%  June 2014
% ------------------------------------------------------------------------ 
% This file is part of the MCG package presented in:
%    Arbelaez P, Pont-Tuset J, Barron J, Marques F, Malik J,
%    "Multiscale Combinatorial Grouping,"
%    Computer Vision and Pattern Recognition (CVPR) 2014.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------

MCG_compute is the package to compute MCG object candidates and UCMs, and benchmark object segmentation algorithms.

FIRST INSTALL
- Change datasets/database_root_dir.m to point to your PASCAL2012 folder (the one with subfolders ImageSets, JPEGImages, etc.) or the SBD or COCO folders.
- Run install.m from the root dir to add the needed paths and do some checks
- If you need to re-build the library (the script install.m will tell if needed), run build.m

USAGE INSTALL
- Each time you restart your matlab, run install.m
- If you want to avoid this, add the paths permanently

MCG USAGE
- To compute MCG candidates, see im2mcg.m (and scripts/im2mcg_all.m)
- To compute MCG UCMs, see im2ucm.m (and scripts/im2ucm_all.m)
- For demos about how to use these functions, see the 'demos' folder

NOTE
- Very big images (around 10 mega-pixels) make the detection of edges at scale 2
  break, so if you really need to handle big images, just use SCG ('fast' mode)

Enjoy!
