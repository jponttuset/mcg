
function eval_list(database, prop_dir, id_file, id_start, id_end, res_dir)


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

        % Input file with candidates as labels
        data_file = fullfile(prop_dir,[curr_id '.mat']);

        % Check if proposals are computed
        if ~exist(data_file, 'file')
            error(['Results ''' data_file '''not found. Have you computed them?']) 
        end
        
        % Load proposals for that image
        proposals = load(data_file);
        
        % Load GT
        gt = db_gt(database,curr_id);

        % Evaluate that result
        [jaccards,inters,false_pos,false_neg,true_areas] = eval_one(proposals, gt);
        
        % Store results
        parsave(res_file,jaccards,inters,false_pos,false_neg,true_areas,gt.category,gt.obj_id,gt.im_id)
    end
end
end


function parsave(res_file,jaccards,inters,false_pos,false_neg,true_areas,obj_classes,obj_ids,image_ids) %#ok<INUSD>
    save(res_file, 'jaccards','inters', 'false_pos', 'false_neg','true_areas','obj_classes','obj_ids','image_ids');
end


