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

database = 'COCO';
gt_set   = 'train2014';

% Read image IDs
im_ids = db_ids(database,gt_set);


%% Go through all image IDs from a certain dataset
for ii = 1:2 % length(im_ids) % <-- Uncomment in a realistic scenario
    % Load image
    im = db_im(database,im_ids{ii});
    
    % Load ground truth
    gt = db_gt(database,im_ids{ii});
   
    % Display
    disp(['Ground truth for image ''' im_ids{ii} ''' has ' num2str(length(gt.masks)) ' objects'])
    
    % Go through all GT objects 
    for jj = 1:length(gt.masks)
        disp([' - Object ' num2str(jj) ' (ID ' num2str(gt.obj_id(jj)) ') has ' num2str(sum(gt.masks{jj}(:))) ' pixels, category ' num2str(gt.category(jj))])
    end
end