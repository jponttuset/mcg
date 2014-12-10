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

%% Some parameters about which result to show
database = 'pascal2012';
gt_set   = 'val2012';
measures  = {'jaccard_object', 'jaccard_class'};

%% Evaluate results as segmented candidates (not bounding boxes)
% Define the number of candidates we will be sampling to plot the 
% evolution of the ranked candidates, i.e., we will evaluate the 
% quality of the first "N" candidates of the set.
% If your candidates are not ranked, you can set just:
%  n_cands = 100000;
% which will evaluate only the full set of candidates.
n_cands = [10:5:100,125:25:1000,1500:500:6000,10000];

% Evaluate you current method here (while training you should
% change gt_set to 'train2012'
% mcg_eval_training = eval_labels('sf_mUCM_multi_3sc_u_4r_12k',database,gt_set,n_cands);

% If already evaluated, the result will be loaded form disk
% This function takes a few minutes to finish
mcg_eval = eval_labels('MCG',database,gt_set,n_cands);
scg_eval = eval_labels('SCG',database,gt_set,n_cands);

% If you want to add your method, you should place your results in a folder
% named 'my_method', inside "datasets/pascal2012", and store one ".mat"
% file for each image with a structure containing the superpixels and the
% labels for each candidate, see 'demo_im2mcg' for an example.

% n_cands = [10:5:100,125:25:1000,1500:500:6000,10000];
% my_method = eval_labels('my_method',database,gt_set,n_cands);


% If your candidates are in the form of boolean masks, you should place
% your results in a folder named 'my_method', inside "datasets/pascal2012",
% and store one ".mat" file for each image with a boolean 3D matrix
% named "masks". Masks should be of the size of the image and the third
% dimension the number of candidates. Set 'compute_masks = 1' in im2mcg
% to see an example.

% This function calls a 'matlabpool' to evaluate the masks in parallel,
% you should adapt the number of workers to your system, since it can take
% a while, depending on the number of candidates
% (hours if you have thousands of candidates). 

% n_cands = [10:5:100,125:25:1000,1500:500:6000,10000];
% my_method = eval_masks('my_method',database,gt_set,n_cands);

% Load pre-computed state-of-the-art results
soa_file = fullfile(root_dir,'results',database,['soa_cands_' gt_set '.mat']);
if exist(soa_file,'file')
    load(soa_file);
    disp(['Loaded: ' soa_file])
end

%% Plot segmented candidate results
figure;
x_limit = 1e4;
titles{1} = {'Maximum achievable quality',['(Pascal segvoc ' gt_set ')'], 'Jaccard at instance level (Ji)'};
titles{2} = {'Maximum achievable quality',['(Pascal segvoc ' gt_set ')'], 'Jaccard at class level (Jc)'};
for jj=1:length(measures)
    subplot(1,2,jj); hold on;
    legends = {};
    
    % Plot MCG
    plot(mcg_eval.mean_n_masks, mcg_eval.(measures{jj}), 'k-')
    legends = {legends{:},'MCG'}; %#ok<CCAT>
    plot(mcg_eval.mean_n_masks, scg_eval.(measures{jj}), 'r-')
    legends = {legends{:},'SCG'}; %#ok<CCAT>
    
    % Plot my_method
%     plot(my_method.mean_n_masks, my_method.(measures{jj}), 'b-')
%     legends = {legends{:},'My method'}; %#ok<CCAT>
    
    % Plot SoA if computed
    if exist('soa','var')
        legends = plot_one_soa(soa, 'cpmc'         , measures{jj}, 'c-' , legends);
        legends = plot_one_soa(soa, 'cat_ind'      , measures{jj}, 'g-' , legends);
        legends = plot_one_soa(soa, 'sh_share'     , measures{jj}, '^r' , legends);
        legends = plot_one_soa(soa, 'reg_parts'    , measures{jj}, 'bo' , legends);
        legends = plot_one_soa(soa, 'sel_search'   , measures{jj}, 'ksq', legends);
        legends = plot_one_soa(soa, 'sel_search_sp', measures{jj}, 'k+' , legends);
        legends = plot_one_soa(soa, 'objectness'   , measures{jj}, 'bsq', legends);
        legends = plot_one_soa(soa, 'objectness_sp', measures{jj}, 'b+' , legends);
    end
        
    % Make plot nicer
    title(strrep(titles{jj},'_','\_'))
    legend(legends,4)
    grid minor
    grid on
    axis([20,x_limit,0.4,0.9])
    set(gca,'XScale','log')
end

% Write values to file
% out_dir = '/Users/jpont/Publications/2014_CVPR/LaTeX/data/obj_cands';
% write_jaccard_to_file(mcg_masks,fullfile(out_dir,[gt_set '_MCG.txt']))


%% Show per-class table
% Select which measure to show 'jaccard_object' or instance (1) or 'jaccard_class' (2)
meas_id = 1;

% Select the sampled number of candidates to show from
%   n_cands = [10:5:100,125:25:1000,1500:500:6000,10000];
res_id = [66 55 19];

% Pascal classes names
classes={'aeroplane', 'bicycle'  , 'bird'       , 'boat'       ,...
         'bottle'   , 'bus'      , 'car'        , 'cat'        ,...
         'chair'    , 'cow'      , 'diningtable', 'dog'        ,...
         'horse'    , 'motorbike', 'person'     , 'pottedplant',...
         'sheep'    , 'sofa'     , 'train'      , 'tvmonitor'  };

% Compute measures
ncands = zeros(length(res_id),1);
all_res = zeros(length(res_id),length(classes)+1);     
for ii=1:length(res_id)
    ncands(ii) = mcg_eval.mean_n_masks(res_id(ii));
    for kk=1:length(classes)
        if meas_id==1
            res = mcg_eval.per_class_results{kk}.meanmax;
        else
            res = mcg_eval.per_class_results{kk}.global_J;
        end
        all_res(ii,kk) = res(res_id(ii));
    end
    res = mcg_eval.(measures{meas_id});
    all_res(ii,end) = res(res_id(ii));
end

% Show table in LaTeX format
disp('ncands   |   Classes                  |  Global')
disp('------------------------------------------------')
for ii=1:length(res_id)
    to_disp = [sprintf('%d',ceil(ncands(ii))) ' & '];
    for kk=1:length(classes)
        to_disp = [to_disp sprintf('%13s',sprintf('%2.1f',100*all_res(ii,kk))) '  & ']; %#ok<AGROW>
    end
    to_disp = [to_disp sprintf('%13s',sprintf('%2.1f',100*all_res(ii,end))) '  \\']; %#ok<AGROW>
    disp(to_disp)
end



