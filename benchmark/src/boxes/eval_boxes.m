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
function stats = eval_boxes(boxes_folder,database,gt_set,n_cands)

if nargin<2
    database = 'pascal2012';
end
if nargin<3
    gt_set = 'val2012';
end
if nargin<4
    % Number of sampled candidates
    n_cands = [10:5:100,125:25:1000,1500:500:6000,10000];
end

% Get the name of the folder to refer to the method
if strcmp(boxes_folder(end),filesep)
    boxes_folder(end) = [];
end
tmp = strfind(boxes_folder,filesep);
if isempty(tmp)
    method_name = boxes_folder;
else
    method_name = boxes_folder(tmp(end)+1:end);
end

res_dir    = fullfile(root_dir,'results',database, [method_name '_boxes']);
stats_file = fullfile(root_dir,'results',database, [method_name '_boxes_' gt_set '.mat']);

% Is the result already gathered?
if exist(stats_file, 'file')
    load(stats_file) 
    recompute = 0;
    disp(['Loaded: ' stats_file '.'])
else
    disp(['RECOMPUTING: ' stats_file '.'])
    recompute = 1;
    
    % Does the folder exist?
    if ~exist(fullfile(root_dir, 'datasets', database, method_name),'dir')
        error(['Nothing found in: ' fullfile(root_dir, 'datasets', database, method_name)])
    end
end

if recompute
    %% Evaluate and save each image independently to be able to parallelize
    % You can adapt the matlabpool to your system
    eval_boxes_parallel(boxes_folder,database,gt_set);
        
    %% Gather and save results
    % Load which images to consider
    im_ids = database_ids(database,gt_set);
    
    % Store and initialize
    stats.n_cands = n_cands;
    stats.gt_set  = gt_set;
    
    % Compute statistics
    stats.num_objects = 0;
    stats.obj_classes = [];
    for ii=1:numel(im_ids)
        res_file = fullfile(res_dir, [im_ids{ii} '.mat']);
        if exist(res_file,'file')
            load(res_file)
            for jj=1:length(stats.n_cands)
                curr_n_cands = min(stats.n_cands(jj), size(jaccards,2));
                to_consider = 1:curr_n_cands;
                stats.all_n_masks(ii,jj) = length(to_consider);
                if (stats.all_n_masks(ii,jj)>0) 
                    for kk=1:size(jaccards,1)
                        stats.max_J(stats.num_objects+kk,jj) = max(jaccards(kk,to_consider));
                    end
                end
            end
            stats.num_objects = stats.num_objects + size(jaccards,1);
            stats.obj_classes = [stats.obj_classes; obj_classes'];
        else
            error([res_file ' not found']);                
        end
    end
   
    stats.mean_n_masks   = mean(stats.all_n_masks);

    % Save result
    save(stats_file,'stats');
    
    % Remove temporal results folder
    rmdir(res_dir,'s');
end
end
