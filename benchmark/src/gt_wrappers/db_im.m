% ------------------------------------------------------------------------ 
%  Copyright (C)
%  ETHZ - Computer Vision Lab
% 
%  Jordi Pont-Tuset <jponttuset@vision.ee.ethz.ch>
%  September 2015
% ------------------------------------------------------------------------ 
% This file is part of the BOP package presented in:
%    Pont-Tuset J, Van Gool, Luc,
%    "Boosting Object Proposals: From Pascal to COCO"
%    International Conference on Computer Vision (ICCV) 2015.
% Please consider citing the paper if you use this code.
% ------------------------------------------------------------------------
function image = db_im( database, image_id )
    if strcmp(database,'Pascal')
        image = imread(fullfile(db_root_dir(database), 'JPEGImages', [image_id '.jpg']));
    elseif strcmp(database,'BSDS500')
        image = imread(fullfile(db_root_dir(database), 'images', [image_id '.jpg']));
    elseif strcmp(database,'SBD')
        image = imread(fullfile(db_root_dir(database), 'img', [image_id '.jpg']));
    elseif strcmp(database,'COCO')
        % Look for the image in the subfodlers to get gt_set
        folds = dir(fullfile(db_root_dir(database),'images'));
        gt_set = '';
        for ii=1:length(folds)
            if (folds(ii).isdir && folds(ii).name(1)~='.')
                if exist(fullfile(db_root_dir(database), 'images', folds(ii).name, [image_id '.jpg']),'file')
                    gt_set = folds(ii).name;
                    image = imread(fullfile(db_root_dir(database), 'images', gt_set, [image_id '.jpg']));
                    break;
                end
            end
        end
        if strcmp(gt_set,'')
            error(['Image not found: ' image_id ' in ' db_root_dir(database)]);
        end
        
    elseif strcmp(database,'ILSVRC')
        % Look for the image in the subfodlers to get gt_set
        folds = dir(fullfile(db_root_dir(database),'images'));
        gt_set = '';
        for ii=1:length(folds)
            if (folds(ii).isdir && folds(ii).name(1)~='.')
                if exist(fullfile(db_root_dir(database), 'images', folds(ii).name, [image_id '.JPEG']),'file')
                    gt_set = folds(ii).name;
                    image = imread(fullfile(db_root_dir(database), 'images', gt_set, [image_id '.JPEG']));
                    break;
                end
            end
        end
        if strcmp(gt_set,'')
            error(['Image not found: ' image_id ' in ' db_root_dir(database)]);
        end
    else
        error(['Unknown database: ' database]);
    end
end

