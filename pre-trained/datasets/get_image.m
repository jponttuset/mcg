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
function image = get_image( database, image_id )
    if strcmp(database,'pascal2012')
        image = imread(fullfile(database_root_dir(database), 'JPEGImages', [image_id '.jpg']));
    elseif strcmp(database,'bsds500')
        image = imread(fullfile(database_root_dir(database), 'images', [image_id '.jpg']));
    else
        error(['Unknown database: ' database]);
    end
end

