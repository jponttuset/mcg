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

% Number of proposals we want to sample in case they are ranked
% If they are not ranked, the full set will be evaluated
n_proposals_ranked = [10:5:100,125:25:1000,1500:500:6000,10000];
n_proposals_single = 1000000;

% Adapt this parameters
method_name = 'MCG';          % Replace 'MCG' by the name of your method folder
database    = 'pascal2012';   % pascal2012, SBD, COCO
gt_set      = 'val2012';
n_proposals = n_proposals_ranked;

% This is the main evaluation function
% - It evaluates the proposals in parallel (adapt eval_parallel to the number of desired processors)
% - It then stores the summary results to file
% - If already computed, it just reloads the results
results = eval_proposals(method_name, database, gt_set, n_proposals);

%% Plot segmented candidate results
measures  = {'jaccard_object', 'jaccard_class'};

% Create figure
figure;

for jj=1:length(measures)
    subplot(1,2,jj); hold on;
           
    plot(results.mean_n_masks, results.(measures{jj}), 'r-+');
    
    % Make plot nicer
    grid minor
    grid on
    axis([20,2e4,0.4,0.9])
    set(gca,'XScale','log')
    
    xlabel('Number of candidates')
    ylabel(strrep(measures{jj},'_','\_'))
end


%% Plot recall at overlap
overlap_levels = [0.5, 0.7, 0.85];

% Create figure
figure;
title(['Recall @ overlap = [' num2str(overlap_levels) ']'])
hold on
grid minor
grid on
set(gca,'XScale','log')

xlabel('Number of candidates')
ylabel('Recall')
    
% Compute and store recall
results.overlap_levels = overlap_levels;
results.rec_at_overlap = [];

for ii = 1:length(overlap_levels)
    results.rec_at_overlap = [results.rec_at_overlap;
                              sum(results.max_J>overlap_levels(ii),1)./repmat(size(results.max_J,1),1,length(results.mean_n_masks))]; 
                          
    plot(results.mean_n_masks, results.rec_at_overlap(ii,:), 'r-+');
                      
end

    
    
