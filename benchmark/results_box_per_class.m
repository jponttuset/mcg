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
databases = {'pascal2012', 'SBD','COCO'};
gt_sets   = {'val2012', 'val', 'val2014'};
soa_ids   = {'MCG','SCG'};
          %    1     2  
ranked = 1; single = 2;
soa_type  = {ranked, ranked}; 
soa_col   = {'k-', 'r-'};

% Which soa at each database
soa_which = {[1 2];[1 2];[1 2]};

% Overlap levelss 
overlap_levels = [0.5 0.7 0.85];

% Number of candidates of the ranked versions (ranked) of the single versions (single)
nc_ranked = [10:5:100,125:25:1000,1500:500:6000,10000];
nc_single = 1000000;
n_cands   = {nc_ranked, nc_single};

%% Sweep all databases and load pre-computed results
for db_id = 1:length(databases)
   database = databases{db_id};

   % Sweep all soa methods and store the results
   for s_id=1:length(soa_which{db_id})
       soa_id = soa_ids{soa_which{db_id}(s_id)};
       soa_tp = soa_type{soa_which{db_id}(s_id)};
       
       % Load pre-computed results
       soa(db_id).(soa_id) = eval_boxes(soa_id, database, gt_sets{db_id}, n_cands{soa_tp}); %#ok<SAGROW>
   end   
end

%% Per-class table (box recall at J=0.5)
J_th  = 0.5;
db_id = 1;
s_id  = 2;

database = databases{db_id};
soa_id = soa_ids{soa_which{db_id}(s_id)};
this_soa = soa(db_id).(soa_id);
% Get the supercategories
if db_id <3
    % Supercateg = classes
    obj_superclasses = this_soa.obj_classes;
    supercat_names = {'Plane','Bicycle','Bird','Boat','Bottle','Bus','Car','Cat','Chair','Cow','Table','Dog','Horse','MBike','Person','Plant','Sheep','Sofa','Train','TV'}; 
else
    % Get COCO
    annFile = fullfile(database_root_dir('COCO'),'annotations',['instances_' gt_sets{db_id} '.json']);
    coco=CocoApi(annFile);
    
    % Get all supercategories
    supercat = containers.Map;
    for ii=1:length(coco.data.categories)
        if ~supercat.isKey(coco.data.categories(ii).supercategory)
            supercat(coco.data.categories(ii).supercategory) = 1;
        end
    end
        
    % Build a LUT
    id = 1;
    supercat_names = cell(1,supercat.length);
    for scat=supercat.keys
        supercat(scat{1}) = id;
        supercat_names{id} = scat{1};
        id = id+1;
    end
   
    % Get the superclass of each object
    all_classes = [coco.data.categories.id];
    obj_superclasses = zeros(size(this_soa.obj_classes));
    for ii=1:length(all_classes)
        sel = logical(all_classes(ii)==this_soa.obj_classes);
        sclass = supercat(coco.data.categories(ii).supercategory);
        obj_superclasses(sel) = sclass;
    end
    assert(sum(obj_superclasses==0)==0)
    % hist(obj_superclasses,[1:12])
end
    
all_superclasses = unique(obj_superclasses);
box_recall = zeros(length(all_superclasses),length(this_soa.mean_n_masks));
for ii=1:length(all_superclasses)
    this_class = logical(obj_superclasses==all_superclasses(ii));
    this_J     = this_soa.max_J(this_class,:);
    box_recall(ii,:) = sum(this_J>J_th)/sum(this_class);
end
box_recall_global = sum(this_soa.max_J>J_th)/size(this_soa.max_J,1);

% Create figure
figure;
% title(['Recall @ overlap = [' num2str(overlap_levels) '] on ' databases{db_id} ' ' strrep(gt_sets{db_id},'_','\_')])
hold on
grid minor
grid on
set(gca,'XScale','log')

set(0,'defaultaxeslinestyleorder',{'-','--','-.'})

plot(this_soa.mean_n_masks,box_recall)
hold on
plot(this_soa.mean_n_masks,box_recall_global,'linewidth',2)
plot(this_soa.mean_n_masks,mean(box_recall),'r','linewidth',2)
legend({supercat_names{:},'Global','Mean over classes'})


%% Write values to file
out_dir = '/Users/jpont/Publications/2014_PAMI_UCB/LaTeX-UPC/data/box_per_class';
write_boxes_per_class_to_file(this_soa.mean_n_masks, box_recall, box_recall_global, supercat_names, fullfile(out_dir,[database '_' gt_sets{db_id} '_' soa_ids{soa_which{db_id}(s_id)} '_boxes_per_class_' num2str(J_th) '.txt']))

