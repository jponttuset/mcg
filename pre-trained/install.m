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

% Check that 'mcg_root' has been set
if ~exist(mcg_root,'dir')
    error('Error installing the package, try updating the value of mcg_root in the file "mcg_root.m"')
end

% Check that 'mcg_root' has the needed folder
if ~exist(fullfile(mcg_root,'lib'),'dir')
    error('Error installing the package, the folder "lib" not found, have you compiled it? See build.m')
end
if ~exist(fullfile(mcg_root,'src'),'dir')
    error('Error installing the package, the folder "src" not found')
end

% Install own lib
addpath(mcg_root);
addpath(fullfile(mcg_root,'lib'));
addpath(fullfile(mcg_root,'scripts'));
addpath(fullfile(mcg_root,'datasets'));
addpath(genpath(fullfile(mcg_root,'src')));

%% Check that the needed functions are compiled
% Included in our code
needed_files = {'mex_assess_one_sel','mex_base_perimeters','mex_fast_features',...
                'mex_fast_intersections', 'mex_fast_reduction', 'mex_box_reduction',...
                'mex_get_tree_cands', 'mex_prune_tree_to_regions',...
                'mex_max_margin', 'mex_hole_filling',...
                'mex_intersect_hierarchies','mex_cands2masks','mex_cands2labels','mex_ucm2hier',...
                'paretofront',...                  % Included from paretofront
                'mexRF_train', 'mexRF_predict',... % Included from RF_Reg_C
                'convConst','gradientMex','imPadMex','imResampleMex','rgbConvertMex',... % Included from piotr_toolbox
                'edgesDetectMex',...               % Included from structured_forest
                'buildW', 'mex_contour_sides', 'ucm_mean_pb',... % Included from BSR
                };
for ii=1:length(needed_files)
    if exist(needed_files{ii})~=3 %#ok<EXIST>
        error(['The needed function (' needed_files{ii} ') not found. Have you built the package properly?'])
    end
end


%% Check that the databases are available and show a warning if not
dbs        = {'pascal2012',    'SBD',   'COCO'};
im_folders = {'JPEGImages', 'images', 'images'};
all_ok = 1;
for ii=1:length(dbs)
    db = dbs{ii};
    if ~exist(fullfile(database_root_dir(db), im_folders{ii}),'dir')
        all_ok = 0;
        disp(['WARNING: Database ' db ' (folder ' im_folders{ii} ') not found in ' database_root_dir(db)])    
    end
end

if ~all_ok
    disp('-- You can disable this warning in install.m --')
end


%% Clear
clear ii needed_files;
disp('-- Successful installation of MCG. Enjoy! --');
