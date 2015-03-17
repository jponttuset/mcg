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
function  write_to_file( stats, filename )

% Create the columns for different recall levels
str_header  = 'ncands\tjac_class\tjac_instance';
str_pattern = '%d\t%f\t%f';
for ii=1:length(stats.overlap_levels)
    str_header = [str_header '\trec_at_' num2str(stats.overlap_levels(ii))]; %#ok<AGROW>
    str_pattern = [str_pattern '\t%f']; %#ok<AGROW>
end
str_header  = [str_header  '\n'];
str_pattern = [str_pattern '\n'];


fid = fopen(filename,'w');
fprintf(fid, str_header);
fprintf(fid, str_pattern, [stats.mean_n_masks; stats.jaccard_class; stats.jaccard_object; stats.rec_at_overlap]);
fclose(fid);


