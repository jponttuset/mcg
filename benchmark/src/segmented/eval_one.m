
function [jaccards,inters,false_pos,false_neg,true_areas] = eval_one(proposals, ground_truth)

    n_objs = length(ground_truth.masks);

    % Store true_areas
    true_areas = zeros(n_objs,1);
    for kk=1:n_objs
        true_areas(kk) = sum(ground_truth.masks{kk}(:));
    end

    % Case when proposals is a subfield
    if isfield(proposals,'proposals')
        proposals = proposals.proposals;
    end
    
    % Which type of result are we evaluating?
    % - Labels: Superpixel matrix + labels for each proposal
    % - Masks : 3D matrix of boolean masks
    % - Blobs : Boolean masks in a bounding box
    % You can add a case in this file to adapt the evaluation to your type
    % of result
    if isfield(proposals,'labels') || isfield(proposals,'indicator_matrix')
        if ~isfield(proposals,'labels')
            if isa(proposals.superpixels,'uint16') 
                superpixels = uint32(proposals.superpixels); % That's RIGOR
            else
                superpixels = uint32(proposals.superpixels'); % That's GOP, transposed
            end

            assert(length(unique(superpixels))==size(proposals.indicator_matrix,1))
            n_cands = size(proposals.indicator_matrix,2);
            labels = cell(n_cands,1);
            for jj=1:n_cands
               labels{jj} = uint32(find(proposals.indicator_matrix(:,jj)'));
            end
        else
            labels = proposals.labels;
            superpixels = proposals.superpixels;
        end
        
        % Handle all as the multiple-superpixels case
        % [jaccards,inters,false_pos,false_neg,true_areas]
        if ~iscell(superpixels)
            superpixels = {superpixels};
            labels = {labels};
        end
        
        jaccards  = [];
        inters    = [];
        false_pos = [];
        false_neg = [];
        
        % Sweep all 'models' (Done for LPO)
        for mm=1:length(superpixels)
            % Overlap superpixels with GT objects
            n_leaves = length(unique(superpixels{mm}));
            superpixels{mm}(~ground_truth.valid_pixels) = 0;
            leave_fp   = zeros(n_objs,n_leaves);  % False positives
            leave_int  = zeros(n_objs,n_leaves);  % Intersection with GT
            for kk=1:n_objs
                tmp = hist(double(superpixels{mm}(:)).*(ground_truth.masks{kk}(:)),(0:n_leaves));
                leave_int(kk,:) = tmp(2:end);
                tmp = hist(double(superpixels{mm}(:)).*(~ground_truth.masks{kk}(:)),(0:n_leaves));
                leave_fp(kk,:) = tmp(2:end);
            end

            % Create matrix padded with zeros to be compatible with mex_eval_labels
            n_proposals  = length(labels{mm});
            n_max_labels = length(unique(superpixels{mm}));
            label_matrix = zeros(n_proposals,n_max_labels);
            for jj=1:n_proposals
                label_matrix(jj,1:length(labels{mm}{jj})) = labels{mm}{jj};
            end

            % Compute fp, fn etc. from these values on the superpixels
            this_inters     = zeros(n_objs,n_proposals);
            this_false_pos  = zeros(n_objs,n_proposals);
            this_false_neg  = zeros(n_objs,n_proposals);
            this_jaccards   = zeros(n_objs,n_proposals);
            if n_proposals>0
                for kk=1:n_objs
                    [this_inters(kk,:),this_false_pos(kk,:)] = mex_eval_labels(leave_int(kk,:),leave_fp(kk,:),label_matrix);
                    this_false_neg(kk,:) = true_areas(kk)-this_inters(kk,:);
                    this_jaccards(kk,:) = this_inters(kk,:)./(this_false_pos(kk,:)+true_areas(kk));
                end
            end
            assert(sum(isnan(this_jaccards(:)))==0)
            
            % Accumulate
            jaccards  = [jaccards  this_jaccards]; %#ok<AGROW>
            inters    = [inters    this_inters];   %#ok<AGROW>
            false_pos = [false_pos this_false_pos];%#ok<AGROW>
            false_neg = [false_neg this_false_neg];%#ok<AGROW>
        end
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
