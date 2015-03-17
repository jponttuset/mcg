
function [jaccards,inters,false_pos,false_neg,true_areas] = eval_one(proposals, ground_truth)

    n_objs = length(ground_truth.masks);

    % Store true_areas
    true_areas = zeros(n_objs,1);
    for kk=1:n_objs
        true_areas(kk) = sum(ground_truth.masks{kk}(:));
    end


    % Which type of result are we evaluating?
    % - Labels: Superpixel matrix + labels for each proposal
    % - Masks : 3D matrix of boolean masks
    % - Blobs : Boolean masks in a bounding box
    % You can add a case in this file to adapt the evaluation to your type
    % of result
    if isfield(proposals,'labels')
        % Overlap superpixels with GT objects
        n_leaves = length(unique(proposals.superpixels));
        superpixels = proposals.superpixels;
        superpixels(~ground_truth.valid_pixels) = 0;
        leave_fp   = zeros(n_objs,n_leaves);  % False positives
        leave_int  = zeros(n_objs,n_leaves);  % Intersection with GT
        for kk=1:n_objs
            tmp = hist(double(superpixels(:)).*(ground_truth.masks{kk}(:)),(0:n_leaves));
            leave_int(kk,:) = tmp(2:end);
            tmp = hist(double(superpixels(:)).*(~ground_truth.masks{kk}(:)),(0:n_leaves));
            leave_fp(kk,:) = tmp(2:end);
        end

        % Create matrix padded with zeros to be compatible with mex_eval_labels
        n_proposals    = length(proposals.labels);
        n_max_labels = length(unique(proposals.superpixels));
        label_matrix = zeros(n_proposals,n_max_labels);
        for jj=1:n_proposals
            label_matrix(jj,1:length(proposals.labels{jj})) = proposals.labels{jj};
        end

        % Compute fp, fn etc. from these values on the superpixels
        inters     = zeros(n_objs,n_proposals);
        false_pos  = zeros(n_objs,n_proposals);
        false_neg  = zeros(n_objs,n_proposals);
        jaccards   = zeros(n_objs,n_proposals);
        if n_proposals>0
            for kk=1:n_objs
                [inters(kk,:),false_pos(kk,:)] = mex_eval_labels(leave_int(kk,:),leave_fp(kk,:),label_matrix);
                false_neg(kk,:) = true_areas(kk)-inters(kk,:);
                jaccards(kk,:) = inters(kk,:)./(false_pos(kk,:)+true_areas(kk));
            end
        end
        assert(sum(isnan(jaccards(:)))==0)
    elseif isfield(proposals,'masks')
        % Sweep and compare all masks
        [areas,inters,false_neg] = mex_eval_masks(proposals.masks,ground_truth.masks,ground_truth.valid_pixels);
        false_pos = repmat(areas,n_objs,1)-inters;
        jaccards = inters./(inters+false_pos+false_neg);
        assert(sum(isnan(jaccards(:)))==0)
    elseif isfield(proposals,'hBlobs')
        % Sweep and compare all blobs
        [areas,inters,false_neg] = mex_eval_blobs(proposals.hBlobs,ground_truth.masks,ground_truth.valid_pixels);
        false_pos = repmat(areas,n_objs,1)-inters;
        jaccards = inters./(inters+false_pos+false_neg);
        assert(sum(isnan(jaccards(:)))==0)
    end
end
