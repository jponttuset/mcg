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
function db_root_dir = db_root_dir( database )
if strcmp(database,'Pascal') || strcmp(database,'COCO') ||  strcmp(database,'SBD') ||  strcmp(database,'ILSVRC') ||  strcmp(database,'BSDS500') || strcmp(database,'bsds_object_gt')
    db_root_dir = fullfile('/srv/glusterfs/jpont/gt_dbs/',database);
else
    error(['Unknown database: ' database]);
end

end

