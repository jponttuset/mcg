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
function eval_boxes_parallel(input_folder,database,gt_set)

if nargin<2
    database = 'pascal2012';
end
if nargin<3
    gt_set = 'val2012';
end

% Get the name of the folder to refer to the method
if strcmp(input_folder(end),filesep)
    input_folder(end) = [];
end
tmp = strfind(input_folder,filesep);
if isempty(tmp)
    method_name = input_folder;
    input_dir = fullfile(root_dir, 'datasets', database, method_name);
else
    method_name = input_folder(tmp(end)+1:end);
    input_dir = input_folder;
end

% Results folder
res_dir   = fullfile(root_dir, 'results', database, [method_name '_boxes']);
if ~exist(res_dir,'dir')
    mkdir(res_dir)
end

% Load which images to consider
im_ids = database_ids(database,gt_set);

% Sweep all images in parallel
matlabpool open;
num_images = numel(im_ids);
parfor ii=1:num_images
    curr_id = im_ids{ii};
    res_file = fullfile(res_dir,[curr_id '.mat']);
    
    % Are these boxes already evaluated?
    if ~exist(res_file, 'file')

        % Check if boxes are computed
        input_file = fullfile(input_dir,[curr_id '.mat']);
        if ~exist(input_file, 'file')
            input_file = fullfile(input_dir,[curr_id '_masks.mat']);
            if ~exist(input_file, 'file')
                input_file = fullfile(input_dir,[curr_id '.txt']);                
                if ~exist(input_file, 'file')
                    error(['Results ''' input_file '/mat''not found. Have you computed them?'])
                end
            end
        end
        
        % Load boxes
        tmp = load(input_file);
        boxes = []; %#ok<NASGU>
        if strcmp(method_name,'EB')
            boxes = [tmp.boxes(:,2), tmp.boxes(:,1), tmp.boxes(:,2)+tmp.boxes(:,4), tmp.boxes(:,1)+tmp.boxes(:,3)];
        elseif strcmp(method_name,'SeSe')
            boxes = tmp.boxes;
        elseif isfield(tmp,'masks')
            boxes = zeros(size(tmp.masks,3),4);
            for jj=1:size(tmp.masks,3)
                boxes(jj,:) = mask2box(tmp.masks(:,:,jj));
            end
        elseif isfield(tmp,'superpixels')
            boxes = labels2boxes(tmp.superpixels, tmp.labels);
        elseif isnumeric(tmp)
            boxes = [tmp(:,2), tmp(:,1), tmp(:,4), tmp(:,3)];
        elseif strcmp(method_name,'Obj') || strcmp(method_name,'RP')
            boxes = round([tmp.boxes(:,2), tmp.boxes(:,1), tmp.boxes(:,4), tmp.boxes(:,3)]);
            boxes(:,boxes(:,1)<1) = 1;
            boxes(:,boxes(:,2)<1) = 1;
        else
            error('Format not recognized');
        end
        
        % Load GT
        gt = get_ground_truth(database,curr_id);
        n_objs = length(gt.masks);
        
        % Sweep all objects
        jaccards = zeros(n_objs,size(boxes,1));
        for jj=1:n_objs
            % Get the bounding box of the GT if it's not already there
            if isfield(gt,'boxes')
                gt_bbox = gt.boxes{jj};
            else
                gt_bbox = mask2box(gt.masks{jj});
            end
            
            % Compare all boxes to gt_bbox
            for kk=1:size(boxes,1)
                jaccards(jj,kk) = boxes_iou(gt_bbox,boxes(kk,:));
            end
        end
        
        % Save
        parsave(res_file,jaccards,gt.category);
    end
end

matlabpool close

end


function parsave(res_file,jaccards,obj_classes) %#ok<INUSD>
    save(res_file, 'jaccards', 'obj_classes');
end

