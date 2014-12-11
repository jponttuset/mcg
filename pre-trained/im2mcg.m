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
% This function computes the MCG candidates given an image.
%  INPUT:
%  - image : Input image
%  - mode  : It can be: + 'fast'     (SCG in the paper)
%                       + 'accurate' (MCG in the paper)
%  - compute_masks : Compute the candidates maks [0] or not [1]. Note that
%                    it is very time consuming. Otherwise use the labels 
%                    as shown in the demo.
%
%  OUTPUT:
%  - candidates : Struct containing the following fields
%          + superpixels : Label matrix of the superpixel partition
%          + labels : Cell containing the superpixel labels that form
%                     each of the candidates
%          + scores : Score of each of the ranked candidates
%          + masks  : 3D boolean matrix containing the masks of the candidates
%                     (only if compute_masks==1)
%  - ucm2       : Ultrametric Contour Map from which the candidates are
%                 extracted
%  - bboxes     : Bounding boxes of the candidates (up,left,down,right)
%                 See 'bboxes' folder for functions to work with them
%
%  DEMO:
%  - See demos/demo_im2mcg.m
% ------------------------------------------------------------------------
function [candidates, ucm2] = im2mcg(image,mode,compute_masks)
if nargin<2
    mode = 'fast';
end
if nargin<3
    compute_masks = 0;
end

% Load pre-trained Structured Forest model
sf_model = loadvar(fullfile(root_dir, 'datasets', 'models', 'sf_modelFinal.mat'),'model');

% Level of overlap to erase duplicates
J_th = 0.95;

% Max margin parameter
theta = 0.7;

if strcmp(mode,'fast')
    % Which scales to work on (MCG is [2, 1, 0.5], SCG is just [1])
    scales = 1;

    % Get the hierarchies at each scale and the global hierarchy
    [ucm2] = img2ucms(image, sf_model, scales);
    all_ucms = ucm2;
    
    % Load pre-trained pareto point
    pareto_n_cands = loadvar(fullfile(root_dir, 'datasets', 'models', 'scg_pareto_point_train2012.mat'),'n_cands');

    % Load pre-trained random forest regresssor for the ranking of candidates
    rf_regressor = loadvar(fullfile(root_dir, 'datasets', 'models', 'scg_rand_forest_train2012.mat'),'rf');

elseif strcmp(mode,'accurate')
    % Which scales to work on (MCG is [2, 1, 0.5], SCG is just [1])
    scales = [2, 1, 0.5];

    % Get the hierarchies at each scale and the global hierarchy
    [ucm2,ucms] = img2ucms(image, sf_model, scales);
    all_ucms = cat(3,ucm2,ucms(:,:,3),ucms(:,:,2),ucms(:,:,1)); % Multi, 0.5, 1, 2

    % Load pre-trained pareto point
    pareto_n_cands = loadvar(fullfile(root_dir, 'datasets', 'models', 'mcg_pareto_point_train2012.mat'),'n_cands');

    % Load pre-trained random forest regresssor for the ranking of candidates
    rf_regressor = loadvar(fullfile(root_dir, 'datasets', 'models', 'mcg_rand_forest_train2012.mat'),'rf');
else
    error('Unknown mode for MCG: Possibilities are ''fast'' or ''accurate''')
end
% ------------------------------------

% Transform ucms to hierarchies (dendogram) and put them all together
n_hiers = size(all_ucms,3);
lps = [];
ms  = cell(n_hiers,1);
ths = cell(n_hiers,1);
for ii=1:n_hiers
    % Transform the UCM to a hierarchy
    curr_hier = ucm2hier(all_ucms(:,:,ii));
    ths{ii}.start_ths = curr_hier.start_ths';
    ths{ii}.end_ths   = curr_hier.end_ths';
    ms{ii}            = curr_hier.ms_matrix;
    lps = cat(3, lps, curr_hier.leaves_part);
end

% Get full cands, represented on a fused hierarchy
[f_lp,f_ms,cands,start_ths,end_ths] = full_cands_from_hiers(lps,ms,ths,pareto_n_cands);

% Hole filling and complementary candidates
if ~isempty(f_ms)
    [cands_hf, cands_comp] = hole_filling(double(f_lp), double(f_ms), cands); %#ok<NASGU>
else
    cands_hf = cands;
    cands_comp = cands; %#ok<NASGU>
end

% Select which candidates to keep (Uncomment just one line)
cands = cands_hf;                       % Just the candidates with holes filled
% cands = [cands_hf; cands_comp];         % Holes filled and the complementary
% cands = [cands; cands_hf; cands_comp];  % All of them
        
% Compute base features
b_feats = compute_base_features(f_lp, f_ms, all_ucms);
b_feats.start_ths = start_ths;
b_feats.end_ths   = end_ths;
b_feats.im_size   = size(f_lp);

% Filter by overlap
red_cands = mex_fast_reduction(cands-1,b_feats.areas,b_feats.intersections,J_th);

% Compute full features on reduced cands
[feats, bboxes] = compute_full_features(red_cands,b_feats);

% Rank candidates
class_scores = regRF_predict(feats,rf_regressor);
[scores, ids] = sort(class_scores,'descend');
red_cands = red_cands(ids,:);
bboxes = bboxes(ids,:);
if isrow(scores)
    scores = scores';
end

% Max margin
[new_ids, mm_scores] = mex_max_margin(red_cands-1,scores,b_feats.intersections,theta); %#ok<NASGU>
cand_labels = red_cands(new_ids,:);
candidates.scores = scores(new_ids);
bboxes = bboxes(new_ids,:); 

% Change the coordinates of bboxes to be coherent with
% other results from other sources (sel_search, etc.)
candidates.bboxes = [bboxes(:,2) bboxes(:,1) bboxes(:,4) bboxes(:,3)];

% Get the labels of leave regions that form each candidates
candidates.superpixels = f_lp;
if ~isempty(f_ms)
    candidates.labels = cands2labels(cand_labels,f_ms);
else
    candidates.labels = {1};
end

% Transform the results to masks
if compute_masks
    if ~isempty(f_ms)
        candidates.masks = cands2masks(cand_labels, f_lp, f_ms);
    else
        candidates.masks = true(size(f_lp));
    end
end