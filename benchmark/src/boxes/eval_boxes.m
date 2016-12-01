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
function stats = eval_boxes(boxes_folder,database,gt_set,n_proposals,random_sampling)

if nargin<2
    database = 'pascal2012';
end
if nargin<3
    gt_set = 'val2012';
end
if nargin<4
    % Number of sampled candidates
    n_proposals = [10:5:100,125:25:1000,1500:500:6000,10000];
end
if nargin<5
    % Do we reduce the candindates randomly?
    random_sampling = 0;
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
end

if recompute
    %% Evaluate and save each image independently to be able to parallelize
    % You can adapt the matlabpool to your system
    %eval_boxes_parallel(boxes_folder,database,gt_set);
        
    %% Gather and save results
    % Load which images to consider
    im_ids = db_ids(database,gt_set);
    
    % Store and pre-allocate
    stats.n_cands = n_proposals;
    stats.gt_set  = gt_set;
    
    stats.all_n_masks = zeros(numel(im_ids),numel(stats.n_cands));
    
    N = 1000000;
    stats.obj_classes   = zeros(N,1);
    stats.obj_ids       = zeros(N,1);
    stats.image_ids     = cell(N,1);
    stats.max_J         = zeros(N,numel(stats.n_cands));
    stats.max_indicator = zeros(N,numel(stats.n_cands));
    
    % Compute statistics
    stats.num_objects = 0;
    for ii=1:numel(im_ids)
        if mod(ii,500)==0
            disp(num2str(ii))
        end
        res_file = fullfile(res_dir, [im_ids{ii} '.mat']);

        if exist(res_file,'file')
        disp(['Loading ' res_file])
            curr = load(res_file);
            for jj=1:length(stats.n_cands)
                % Which candidates to consider
                % (first N for ranked or random)
                if random_sampling
                    if stats.n_cands(jj)>=size(curr.jaccards,2)
                        to_consider = 1:size(curr.jaccards,2);
                    else
                        to_consider = randsample(size(curr.jaccards,2),stats.n_cands(jj));
                    end
                else
                    curr_n_cands = min(stats.n_cands(jj), size(curr.jaccards,2));
                    to_consider = 1:curr_n_cands;
                end
                stats.all_n_masks(ii,jj) = length(to_consider);
                if (stats.all_n_masks(ii,jj)>0) 
                    for kk=1:size(curr.jaccards,1)
                        [stats.max_J(stats.num_objects+kk,jj), which_one] = max(curr.jaccards(kk,to_consider));
                        stats.max_indicator(stats.num_objects+kk,jj) = to_consider(which_one);
                    end
                end
            end
            stats.obj_classes(stats.num_objects+1:stats.num_objects+kk) = curr.obj_classes;
            stats.obj_ids    (stats.num_objects+1:stats.num_objects+kk) = curr.obj_ids;
            stats.image_ids  (stats.num_objects+1:stats.num_objects+kk) = curr.image_ids;
            
            stats.num_objects = stats.num_objects + size(curr.jaccards,1);
        else
            error([res_file ' not found']);
        end
    end
   
    % Resize to fit the number of objects
    stats.obj_classes   = stats.obj_classes(1:stats.num_objects);
    stats.obj_ids       = stats.obj_ids(1:stats.num_objects);
    stats.image_ids     = stats.image_ids(1:stats.num_objects);
    stats.max_J         = stats.max_J(1:stats.num_objects,:);
    stats.max_indicator = stats.max_indicator(1:stats.num_objects,:);
  
    stats.mean_n_masks   = mean(stats.all_n_masks);
    
    % ----- Jaccard at instance level (J_i) ----
    % It is the mean best jaccard for all objects
    stats.jaccard_object = mean(stats.max_J);
    % ----

    
    % ----- Compute recalls ----
    stats.recall_05  = sum(stats.max_J>0.5,1)/size(stats.max_J,1);
    stats.recall_07  = sum(stats.max_J>0.7,1)/size(stats.max_J,1);
    stats.recall_085 = sum(stats.max_J>0.85,1)/size(stats.max_J,1);
    stats.average_recall = zeros(1,size(stats.max_J,2));
    for ll=1:size(stats.max_J,2)
        stats.average_recall(ll) = average_recall(stats.max_J(:,ll));
    end
    % ----
    
    
    % ----- Compute per-category recalls ----
    class_ids = unique(stats.obj_classes);
    for ii=1:length(class_ids)
        stats.per_class_results{ii}.max_J      = stats.max_J(logical(stats.obj_classes==class_ids(ii)),:);
        curr_J = stats.per_class_results{ii}.max_J;
        stats.per_class_results{ii}.recall_05  = sum(curr_J>0.5,1)/size(curr_J,1);
        stats.per_class_results{ii}.recall_07  = sum(curr_J>0.7,1)/size(curr_J,1);
        stats.per_class_results{ii}.recall_085 = sum(curr_J>0.85,1)/size(curr_J,1);
        stats.per_class_results{ii}.average_recall = zeros(1,size(curr_J,2));
        for ll=1:size(curr_J,2)
            stats.per_class_results{ii}.average_recall(ll) = average_recall(curr_J(:,ll));
        end
    end
    % ----
        
    save(stats_file,'stats','-v7.3');
    
    % Remove temporal results folder
%     rmdir(res_dir,'s');
end
end
