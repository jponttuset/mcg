
function eval_boxes_list(database, prop_dir, id_file, id_start, id_end, res_dir)


disp(['prop_dir = ', prop_dir])
disp(['id_file  = ', id_file])
disp(['id_start = ', num2str(id_start)])
disp(['id_end   = ', num2str(id_end)])
disp(['res_dir  = ', res_dir])

% Read id file
fileID = fopen(id_file);
ids = textscan(fileID, '%s');
ids = ids{1};
fclose(fileID);

% Process only the ones selected
ids = ids(id_start:id_end);

for ii=1:length(ids)
    curr_id = ids{ii};
    res_file = fullfile(res_dir,[curr_id '.mat']);
    
    % Are these proposals already evaluated?
    if ~exist(res_file, 'file')
          
        % Check if boxes are computed
        input_file = fullfile(prop_dir,[curr_id '.mat']);
        if ~exist(input_file, 'file')
            input_file = fullfile(prop_dir,[curr_id '_masks.mat']);
            if ~exist(input_file, 'file')
                input_file = fullfile(prop_dir,[curr_id '.json']);
                if ~exist(input_file, 'file')
                    input_file = fullfile(prop_dir,[curr_id '.txt']);
                    if ~exist(input_file, 'file')
                        error(['Results ''' input_file '/mat/json''not found. Have you computed them?'])
                    end
                end
            end
        end
        
        % Load boxes
        [~,method_name] = fileparts(strip(prop_dir,'right',filesep));
        
        [~,~,ext] = fileparts(input_file);
        if strcmp(ext,'.json')
            % Get and sort proposals
            proposals = gason(fileread(input_file));
            [~,s_id] = sort([proposals.score],'descend');
            proposals = proposals(s_id);
            boxes = reshape([proposals.bbox],[4,length(proposals)])';
            boxes = [boxes(:,2)+1 boxes(:,1)+1 boxes(:,2)+boxes(:,4) boxes(:,1)+boxes(:,3)];
        else
            tmp = load(input_file);
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
            elseif strcmp(method_name,'Obj') || strcmp(method_name,'RP') || strcmp(method_name,'RPN_VOC07') || strcmp(method_name,'RPN')
                boxes = round([tmp.boxes(:,2), tmp.boxes(:,1), tmp.boxes(:,4), tmp.boxes(:,3)]);
                boxes(:,boxes(:,1)<1) = 1;
                boxes(:,boxes(:,2)<1) = 1;
            elseif isfield(tmp,'boxes')
                boxes = tmp.boxes;
            else
                error('Format not recognized');
            end
        end
        
        % Load GT
        gt = db_gt(database,curr_id);
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
        parsave(res_file,jaccards,gt.category,gt.obj_id,gt.im_id);
    end
end
end


function parsave(res_file,jaccards,obj_classes,obj_ids,image_ids) %#ok<INUSD>
    save(res_file, 'jaccards','obj_classes','obj_ids','image_ids');
end



