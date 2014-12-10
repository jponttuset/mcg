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
function rank_training(params)

n_hiers = length(params.hiers);

%% Load Pareto parameters
n_cands = loadvar(params.files.pareto_point,'n_cands');

% Some checks
assert(n_hiers==size(n_cands,2));
assert(params.n_r_cand==size(n_cands,1));

%% Gather all features and quality of the training set candidates
if exist(params.files.features_file,'file')
    load(params.files.features_file);
    disp(['Loaded: ' params.files.features_file '.'])
else
    disp(['RECOMPUTING: ' params.files.features_file '.'])

    features = [];
    jaccards = [];

    % Load which images to consider from the params.database (train, val, etc.)
    im_ids = database_ids(params.database,params.gt_set_ranking);

    num_images = length(im_ids);
    for im_id = 1:num_images

        % Read all hierarchies
        lps = [];
        ms  = cell(n_hiers,1);
        ths = cell(n_hiers,1);
        all_ucms = [];
        for ii=1:n_hiers
            % Read all UCMs at different scales
            clear ucm2;
            load(fullfile(params.hier_dirs{ii}, [im_ids{im_id} '.mat']));
            all_ucms = cat(3,all_ucms,ucm2);

            % Read the UCM as a hierarchy
            curr_hier = ucm2hier(ucm2);
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
        feats = compute_full_features(red_cands,b_feats);

        % Eval candidates
        gt = get_ground_truth(params.database, im_ids{im_id});
        hier.leaves_part = f_lp;
        hier.ms_struct = ms_matrix2struct(f_ms);
        jacc = eval_cands(hier, red_cands, gt);
        max_jacc = max(jacc,[],1)';

        % Sample candidates
        % Get the optimum candidates for each object
        % to ensure they are on the training set
        [~,ids] = max(jacc,[],2);
        if (length(ids)>params.n_samples)  % More objects than samples asked
            ids = ids(1:params.n_samples);
        end
        ids_rest = setdiff(1:size(jacc,2),ids);
        if (size(jacc,2)-length(ids))>params.n_samples
            ids_rest = ids_rest(randperm(length(ids_rest),params.n_samples-length(ids)));
        end
        if isrow(ids_rest)
            ids_rest = ids_rest';
        end
        sel_ids = [ids; ids_rest];

        % Store
        features = [features; feats(sel_ids,:)]; %#ok<AGROW>
        jaccards = [jaccards; max_jacc(sel_ids,:)]; %#ok<AGROW>
    end

    save(params.files.features_file,'features','jaccards');
end

%% Train the random forest
if exist(params.files.trained_classifier,'file')
    disp(['Already trained: ' params.files.trained_classifier '.'])
else
    disp(['TRAINING: ' params.files.trained_classifier '.'])

    % Train and save the result
    rf = regRF_train(features,jaccards,50); %#ok<NASGU>
    disp('Training done')

    % Save the result
    save(params.files.trained_classifier,'rf');
end