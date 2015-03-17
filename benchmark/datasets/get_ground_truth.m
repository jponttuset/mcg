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
function ground_truth = get_ground_truth( database, image_id )

    if strcmp(database,'pascal2012') || strcmp(database,'SBD')
        
        % Load Object and Class ground truth
        gt_object = imread(fullfile(database_root_dir(database), 'SegmentationObject', [image_id '.png']));
        gt_class  = imread(fullfile(database_root_dir(database), 'SegmentationClass', [image_id '.png']));
        
        % Transform ground truth into separate masks and classes into ids
        % (to be compatible with COCO)
        obj_ids   = unique(gt_object);
        obj_ids(obj_ids==0) = [];
        obj_ids(obj_ids==255) = [];
        for ii=1:length(obj_ids)
            ground_truth.masks{ii} = (gt_object==obj_ids(ii));
            ground_truth.category(ii) = gt_class(find(ground_truth.masks{ii}==1,1,'first'));
        end
        
        % Valid pixels
        ground_truth.valid_pixels = (gt_object<255);
        
    elseif strcmp(database,'COCO')
        
        % Look for the image in the three datasets
        if exist(fullfile(database_root_dir(database), 'images','train2014', [image_id '.jpg']),'file')
            gt_set = 'train2014';
        elseif exist(fullfile(database_root_dir(database), 'images', 'val2014', [image_id '.jpg']),'file')
            gt_set = 'val2014';
        elseif exist(fullfile(database_root_dir(database), 'images', 'test2014', [image_id '.jpg']),'file')
            gt_set = 'test2014';
        else
            error(['Image not found: ' image_id ' in ' database_root_dir(database)]);
        end
        
        % Get image to know the size
        im = imread(fullfile(database_root_dir(database), 'images', gt_set, [image_id '.jpg']));
        
        % Get COCO api for instance annotations (we store it to the 'base'
        % workspace to avoid having to read it every time)
        annFile = fullfile(database_root_dir('COCO'),'annotations',['instances_' gt_set '.json']);
        if ~evalin('base',['exist(''coco_' gt_set ''',''var'')'])
            disp(['Loading ' annFile])
            evalin('base',['coco_' gt_set '=CocoApi(''' annFile ''');']);
        end
        coco = evalin('base', ['coco_' gt_set]);
        
        % Extract the image number out of the id
        undersc = strfind(image_id,'_');
        assert(length(undersc)==2);
        im_id  = str2double(image_id(undersc(2)+1:end));
        annIds = coco.getAnnIds('imgIds',im_id);
        anns   = coco.loadAnns(annIds);
        
        % Get the masks and categories for that image (ignoring crowd)
        jj=1;
        for ii=1:length(anns)
            if ~anns(ii).iscrowd
                ground_truth.masks{jj} = coco.segToMask(anns(ii).segmentation, size(im,1), size(im,2));
                ground_truth.boxes{jj} = round([anns(ii).bbox(2) anns(ii).bbox(1) anns(ii).bbox(2)+anns(ii).bbox(4) anns(ii).bbox(1)+anns(ii).bbox(3)]);
                ground_truth.boxes{jj}(ground_truth.boxes{jj}<=0) = 1;
                if(ground_truth.boxes{jj}(3)>size(im,1))
                    ground_truth.boxes{jj}(3) = size(im,1);
                end
                if(ground_truth.boxes{jj}(4)>size(im,2))
                    ground_truth.boxes{jj}(4) = size(im,2);
                end
                ground_truth.category(jj) = anns(ii).category_id;
                jj = jj+1;
            end
        end
        
        % If it's empty
        if ~exist('ground_truth','var')
            ground_truth.masks    = cell(0);
            ground_truth.boxes    = cell(0);
            ground_truth.category = [];
        end
        
        % All valid pixels (to make it compatible with SBD and Pascal)
        ground_truth.valid_pixels = true(size(im,1),size(im,2));
        
    else
        error(['Unknown database: ' database]);
    end
end

