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
databases = {'Pascal','SBD','COCO'};
gt_sets   = {'Segmentation_val_2012', 'val', 'val2014'};
soa_ids   = {'MCG','SCG','CI','GOP','GLS','SeSe','RIGOR','RP','ShSh','QT', 'CPMC', 'LPO', 'POISE400', 'POISE1000', 'POISE4000'};
          %    1     2    3     4     5     6       7     8     9     10     11     12        13          14            15 
ranked = 1; single = 2;
soa_type  = {ranked, ranked, ranked, single, single, single, single, single, single, ranked, single, single, single, single, single};
soa_col   = {'k-', 'r-', 'c-', 'b+', 'gs', 'bo', '^r', 'm*', 'b>', 'k--', 'g-', 'ks','rs','rs','rs'};

% Which soa at each database
soa_which = {[1 2 3 4 5 6 7 9 10 11 12 13 14 15 16]; 
             [1 2   4 5 6 7   10 11 12 13 14 15];
             [1 2   4 5 6 7   10    12 13 14 15]}; 


%% Sweep all databases and load pre-computed results
for db_id = 1:length(databases)
    database = databases{db_id};
    
    % Sweep all soa methods and store the results
    for s_id=1:length(soa_which{db_id})
        soa_id = soa_ids{soa_which{db_id}(s_id)};
        soa_tp = soa_type{soa_which{db_id}(s_id)};
        
        % Show warning if not found
        if ~exist(fullfile(root_dir,'results',database, [soa_id '_' database '_' gt_sets{db_id} '.mat']),'file')
            fprintf(2,'Precomputed results not found: ''%s''\nHave you downloaded them? You can find them in:\n - https://data.vision.ee.ethz.ch/jpont/mcg/eval/Pascal.zip\n - https://data.vision.ee.ethz.ch/jpont/mcg/eval/SBD.zip\n - https://data.vision.ee.ethz.ch/jpont/mcg/eval/COCO.zip\nDownload them and put them in a folder called ''results''.\n', fullfile(root_dir,'results',database, [soa_id '_' database '_' gt_sets{db_id} '.mat']));
        end
        
        % Load pre-computed results or re-evaluate
        soa(db_id).(soa_id) = eval_proposals(soa_id, database, gt_sets{db_id}); %#ok<SAGROW>
    end
end


%% Plot segmented candidate results
measures  = {'jaccard_object', 'jaccard_class'};
for db_id = 1:length(databases)
    % Create figure
    figure;
    titles{1} = {'Maximum achievable quality',['(' databases{db_id} ' ' gt_sets{db_id} ')'], 'Jaccard at instance level (Ji)'};
    titles{2} = {'Maximum achievable quality',['(' databases{db_id} ' ' gt_sets{db_id} ')'], 'Jaccard at class level (Jc)'};

    for jj=1:length(measures)
        subplot(1,2,jj); hold on;
           
        for s_id=1:length(soa_which{db_id})
            curr_soa = soa(db_id).(soa_ids{soa_which{db_id}(s_id)});
            if (soa_type{soa_which{db_id}(s_id)}==ranked)
                plot(curr_soa.mean_n_masks, curr_soa.(measures{jj}), soa_col{soa_which{db_id}(s_id)});
            else
                curr_vals = curr_soa.(measures{jj});
                plot(curr_soa.mean_n_masks(end), curr_vals(end), soa_col{soa_which{db_id}(s_id)});
            end
        end

        % Make plot nicer
        title(strrep(titles{jj},'_','\_'))
        grid minor
        grid on
        axis([20,2e4,0.2,0.9])
        set(gca,'XScale','log')
        
        % Legend
        legend(soa_ids(soa_which{db_id}),2) 
    end    
end


%% Plot recall (choose which measure)
measure = 'average_recall';
% measure = 'recall_05';
% measure = 'recall_07';
% measure = 'recall_085';
for db_id = 1:length(databases)

    % Create figure
    figure;
    title(['Recall (' strrep(measure,'_','\_') ') on ' databases{db_id} ' ' strrep(gt_sets{db_id},'_','\_')])
    hold on
    grid minor
    grid on
    set(gca,'XScale','log')

    xlabel('Number of proposals')
    ylabel('Recall')

    for s_id=1:length(soa_which{db_id})
        curr_soa = soa(db_id).(soa_ids{soa_which{db_id}(s_id)});
        curr_recall = curr_soa.(measure);
        if soa_type{soa_which{db_id}(s_id)}==ranked
            plot(curr_soa.mean_n_masks, curr_recall, soa_col{soa_which{db_id}(s_id)});
        else
            plot(curr_soa.mean_n_masks(end), curr_recall(end), soa_col{soa_which{db_id}(s_id)});
        end
    end
    
    % Legend
    legend(soa_ids(soa_which{db_id}),2) 
end

%% Write values to file
out_dir = '/Users/jpont/Publications/2015_ICCV/LaTeX/data/obj_cands/';
for db_id = 1:length(databases)
    for s_id=1:length(soa_which{db_id})
        database = databases{db_id};
        curr_soa = soa(db_id).(soa_ids{soa_which{db_id}(s_id)});
        curr_n_prop = curr_soa.mean_n_masks;
        if soa_type{soa_which{db_id}(s_id)}==ranked
            sel_ids = find(curr_n_prop>=50);
        else
            sel_ids = length(curr_n_prop);
        end
        write_to_file(fullfile(out_dir,[database '_' gt_sets{db_id} '_' soa_ids{soa_which{db_id}(s_id)} '.txt']),...
                       {'ncands', 'jac_instance', 'average_recall', 'rec_at_0.5', 'rec_at_0.7', 'rec_at_0.85'},...
                        [curr_n_prop(sel_ids)', curr_soa.jaccard_object(sel_ids)',...
                                                curr_soa.average_recall(sel_ids)',...
                                                curr_soa.recall_05(sel_ids)',...
                                                curr_soa.recall_07(sel_ids)',...
                                                curr_soa.recall_085(sel_ids)'])
    end
end
