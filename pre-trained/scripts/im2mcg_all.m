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
% Script to compute MCG or SCG candidates on a whole dataset
%
% ------------------------------------------------------------------------
function im2mcg_all(mode, database, gt_set)
if nargin==0
    mode = 'fast';
end
if nargin<2
    database = 'pascal2012';
end
if nargin<3
    gt_set = 'val2012';
end

% Create out folder
if strcmp(mode,'fast')
    res_dir = fullfile(root_dir,'datasets',database,'SCG');
elseif strcmp(mode,'accurate')
    res_dir = fullfile(root_dir,'datasets',database,'MCG');
else
    error('Unknown mode for MCG: Possibilities are ''fast'' or ''accurate''')
end
if ~exist(res_dir,'dir')
    mkdir(res_dir);
end

% Load which images to consider from the database (train, val, etc.)
im_ids = database_ids(database,gt_set);

% Sweep all images and process them in parallel
matlabpool(4);
num_images = length(im_ids);
parfor im_id = 1:num_images 
    % File to store the candidates
    res_file   = fullfile(res_dir,[im_ids{im_id} '.mat']);

    % Do not recompute if already computed
    if ~exist(res_file,'file')
        % Read the image
        image = get_image(database, im_ids{im_id});

        % Call the MCG code
        candidates = im2mcg(image,mode);

        % Store the masks results  
        parsave(res_file,candidates);
    end
end
matlabpool close
end

function parsave(res_file,candidates)
    scores = candidates.scores; %#ok<NASGU>
    bboxes = candidates.bboxes; %#ok<NASGU>
    superpixels = candidates.superpixels; %#ok<NASGU>
    labels = candidates.labels; %#ok<NASGU>
    save(res_file,'scores','bboxes','superpixels','labels');
end
