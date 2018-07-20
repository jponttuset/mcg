function ar = average_recall(J, overlap_levels)

if ~exist('overlap_levels','var')
    % overlap_levels = 0.5:0.05:1; % Hosang et al. paper (boxes)
    overlap_levels = 0.5:0.05:0.95; % MS-COCO
end

% Recall for all levels
recs = zeros(1,length(overlap_levels));
for kk = 1:length(overlap_levels)
    recs(kk) = sum(J>=overlap_levels(kk))/length(J); 
end

% Compute mean
ar = mean(recs);

end
