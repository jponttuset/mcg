% ------------------------------------------------------------------------ 
%  Copyright (C)
%  ETHZ - Computer Vision Lab
% 
%  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
%  September 2015
% ------------------------------------------------------------------------ 
% This file is part of the BOP package presented in:
%    Pont-Tuset J, Van Gool, Luc,
%    "Boosting Object Proposals: From Pascal to COCO"
%    International Conference on Computer Vision (ICCV) 2015.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
function ids = db_ids( database, gt_set )
    index_file = fullfile(gt_wrappers_root, 'gt_sets', database, [gt_set '.txt']);
    fileID = fopen(index_file);
    ids = textscan(fileID, '%s');
    ids = ids{1};
    fclose(fileID);
end

