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
function compute_mcg_cands(params)
if nargin==0
    params = get_params();
end

res_dir = fullfile(root_dir,'datasets',params.database,params.mcg_id);
if ~exist(res_dir,'dir')
    mkdir(res_dir);
end

n_hiers = length(params.hier_dirs);

% Load trained random forest
rf = loadvar(params.files.trained_classifier,'rf');

% Load Pareto parameters
n_cands = loadvar(params.files.pareto_point,'n_cands');

% Number of regions per candidate
assert(n_hiers==size(n_cands,2));

% Load which images to consider from the params.database (train, val, etc.)
im_ids = database_ids(params.database,params.gt_set_test);

% Sweep all images
matlabpool(4);
num_images = length(im_ids);
parfor im_id = 1:num_images
    
    % File to store the candidates
    res_file = fullfile(res_dir,[im_ids{im_id} '.mat']);

    % Is it already computed?
    if ~exist(res_file,'file')

        % Read all hierarchies
        tic
        lps = [];
        ms  = cell(n_hiers,1);
        ths = cell(n_hiers,1);
        all_ucms = [];
        for ii=1:n_hiers
            % Read all UCMs at different scales
            curr_ucm = load(fullfile(params.hier_dirs{ii}, [im_ids{im_id} '.mat'])); %#ok<PFBNS>
            all_ucms = cat(3,all_ucms,curr_ucm.ucm2);

            % Read the UCM as a hierarchy
            curr_hier = ucm2hier(curr_ucm.ucm2);
            ths{ii}.start_ths = curr_hier.start_ths';
            ths{ii}.end_ths = curr_hier.end_ths';
            ms{ii} = curr_hier.ms_matrix;
            lps = cat(3, lps, curr_hier.leaves_part);
        end

        % Get full cands, represented on a fused hierarchy
        [f_lp,f_ms,cands,start_ths,end_ths] = full_cands_from_hiers(lps,ms,ths,n_cands);

        % Hole filling and complementary candidates
        [cands_hf, cands_comp] = hole_filling(double(f_lp), double(f_ms), cands); %#ok<NASGU>
        
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
        red_cands = mex_fast_reduction(cands-1,b_feats.areas,b_feats.intersections,params.J_th);

        % Compute full features on reduced cands
        [feats, bboxes] = compute_full_features(red_cands,b_feats);

        % Rank candidates
        class_scores = regRF_predict(feats,rf);
        [scores, ids] = sort(class_scores,'descend');
        red_cands = red_cands(ids,:);
        bboxes = bboxes(ids,:);
        if isrow(scores)
            scores = scores';
        end
        
        % Max margin
        candidates=[];
        [new_ids, mm_scores] = mex_max_margin(red_cands-1,scores,b_feats.intersections,params.theta); %#ok<NASGU>
        cand_labels = red_cands(new_ids,:);
        candidates.scores = scores(new_ids);
        bboxes = bboxes(new_ids,:); 

        % Change the coordinates of bboxes to be coherent with
        % other results from other sources (sel_search, etc.)
        candidates.bboxes = [bboxes(:,2) bboxes(:,1) bboxes(:,4) bboxes(:,3)];

        % Get the labels of leave regions that form each candidates
        candidates.superpixels = f_lp;
        candidates.labels = cands2labels(cand_labels,f_ms);
        
        % Save
        parsave(res_file,candidates);
    end
end
end

function parsave(res_file,candidates)
    scores = candidates.scores; %#ok<NASGU>
    bboxes = candidates.bboxes; %#ok<NASGU>
    superpixels = candidates.superpixels; %#ok<NASGU>
    labels = candidates.labels; %#ok<NASGU>
    save(res_file,'scores','bboxes','superpixels','labels');
end
