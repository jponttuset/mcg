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
% Please note that for BSDS500, you should put all *.mat from test, val,
% and train in the same folder
% ------------------------------------------------------------------------

function ground_truth = get_ground_truth( database, image_id )
    if strcmp(database,'pascal2012')
        ground_truth.object = imread(fullfile(database_root_dir(database), 'SegmentationObject', [image_id '.png']));
        ground_truth.class  = imread(fullfile(database_root_dir(database), 'SegmentationClass', [image_id '.png']));
    elseif strcmp(database,'bsds500')
        ground_truth = loadvar(fullfile(database_root_dir(database), 'groundTruth', [image_id '.mat']),'gt_seg');
    else
        error(['Unknown database: ' database]);
    end
end

