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

function all_recalls = recallatoverlap(stats, all_overlaps, n_masks_id)

if nargin<3
    curr_stats = stats.max_J(:,end);
else
    if n_masks_id>size(stats.max_J,2)
        curr_stats = stats.max_J(:,end);
    else
        curr_stats = stats.max_J(:,n_masks_id);
    end
end

all_recalls = zeros(size(all_overlaps));
for ii=1:length(all_overlaps)
    all_recalls(ii) = sum(curr_stats>all_overlaps(ii))/length(curr_stats);
end