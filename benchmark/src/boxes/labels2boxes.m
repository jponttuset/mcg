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
function boxes = labels2boxes(superpixels, labels)

% Get boxes of the superpixels
tmp = regionprops(superpixels,'BoundingBox');
tmp = cat(1,tmp.BoundingBox);
sp_bboxes = [tmp(:,2)+0.5, tmp(:,1)+0.5, tmp(:,2)+tmp(:,4)-0.5, tmp(:,1)+tmp(:,3)-0.5];

% Compute the boxes of the labels from those of the superpixels
boxes = zeros(length(labels),4);
for ii=1:length(labels)
    curr_sp_bboxes = sp_bboxes(labels{ii},:);
    boxes(ii,1) = min(curr_sp_bboxes(:,1));
    boxes(ii,2) = min(curr_sp_bboxes(:,2));
    boxes(ii,3) = max(curr_sp_bboxes(:,3));
    boxes(ii,4) = max(curr_sp_bboxes(:,4));
end

