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
function  write_boxes_per_class_to_file(mean_n_masks, box_recall, box_recall_global, class_names, filename )

% Create the columns for different recall levels
str_header  = 'ncands';
str_pattern = '%d';
for ii=1:length(class_names)
    str_header = [str_header '\t' class_names{ii}]; %#ok<AGROW>
    str_pattern = [str_pattern '\t%f']; %#ok<AGROW>
end
str_header  = [str_header  '\tglobal\tmean_over_classes\n'];
str_pattern = [str_pattern '\t%f\t%f\n'];


fid = fopen(filename,'w');
fprintf(fid, str_header);
fprintf(fid, str_pattern, [mean_n_masks; box_recall; box_recall_global; mean(box_recall)]);
fclose(fid);