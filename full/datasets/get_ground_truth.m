function ground_truth = get_ground_truth( database, image_id )
    if strcmp(database,'pascal2012')
        ground_truth.object = imread(fullfile(database_root_dir(database), 'SegmentationObject', [image_id '.png']));
        ground_truth.class  = imread(fullfile(database_root_dir(database), 'SegmentationClass', [image_id '.png']));
    elseif strcmp(database,'bsds500')
        ground_truth = loadvar(fullfile(database_root_dir(database), 'ground_truth', [image_id '.mat']),'gt_seg');
    else
        error(['Unknown database: ' database]);
    end
end

