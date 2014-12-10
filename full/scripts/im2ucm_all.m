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
%
% Script to compute MCG or SCG UCMs on a whole dataset
%
% ------------------------------------------------------------------------
function im2ucm_all(mode, database, gt_set)
if nargin==0
    mode = 'accurate';
end
if nargin<2
    database = 'pascal2012';
end
if nargin<3
    gt_set = 'val2012';
end

% Create out folder
if strcmp(mode,'fast')
    res_dir = fullfile(root_dir,'datasets',database,'SCG-ucm');
elseif strcmp(mode,'accurate')
    res_dir = fullfile(root_dir,'datasets',database,'MCG-ucm');
else
    error('Unknown mode for MCG: Possibilities are ''fast'' or ''accurate''')
end
if ~exist(res_dir,'dir')
    mkdir(res_dir);
end
    
% Which images to process
im_ids = database_ids(database,gt_set);

% Sweep all images and process them in parallel
matlabpool(4);
parfor ii=1:length(im_ids)
    % Read image
    im = get_image(database,im_ids{ii});
    
    % Check if the result is already computed
    if ~exist(fullfile(res_dir,[im_ids{ii} '.mat']),'file')
        
        % Call the actual code
        ucm2 = im2ucm(im, mode);
        
        % Store ucms at each scale separately
        parsave(fullfile(res_dir,[im_ids{ii} '.mat']),ucm2)
    end
end
matlabpool close

end


function parsave(res_file,ucm2) %#ok<INUSD>
    save(res_file,'ucm2');
end
