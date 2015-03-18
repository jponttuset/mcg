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
function eval_parallel(proposals_folder,database,gt_set)

% Get the name of the folder to refer to the method
if strcmp(proposals_folder(end),filesep)
    proposals_folder(end) = [];
end
tmp = strfind(proposals_folder,filesep);
if isempty(tmp)
    method_name = proposals_folder;
    proposals_dir = fullfile(root_dir, 'datasets', database, method_name);
else
    method_name = proposals_folder(tmp(end)+1:end);
    proposals_dir = proposals_folder;
end

% Results folder
res_dir   = fullfile(root_dir, 'results', database, method_name);
if ~exist(res_dir,'dir')
    mkdir(res_dir)
end

% Load which images to consider
im_ids = database_ids(database,gt_set);

% Sweep all images
matlabpool open
num_images = numel(im_ids);
parfor ii=1:num_images
    curr_id = im_ids{ii};
    res_file = fullfile(res_dir,[curr_id '.mat']);
    
    % Are these candidates already evaluated?
    if ~exist(res_file, 'file')

        % Input file with candidates as labels
        data_file = fullfile(proposals_dir,[curr_id '.mat']);

        % Check if proposals are computed
        if ~exist(data_file, 'file')
            error(['Results ''' data_file '''not found. Have you computed them?']) 
        end
        
        % Load proposals for that image
        proposals = load(data_file);
        
        % Load GT
        gt = get_ground_truth(database,curr_id);

        % Evaluate that result
        [jaccards,inters,false_pos,false_neg,true_areas] = eval_one(proposals, gt);
        
        % Store results
        parsave(res_file,jaccards,inters,false_pos,false_neg,true_areas,gt.category)
    end
end
matlabpool close
end


function parsave(res_file,jaccards,inters,false_pos,false_neg,true_areas,obj_classes) %#ok<INUSD>
    save(res_file, 'jaccards','inters', 'false_pos', 'false_neg','true_areas','obj_classes');
end

