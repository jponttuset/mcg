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
function write_to_file(filename, headers, data )

% Create header and pattern string
assert(length(headers)==size(data,2))
str_pattern = '%f';
str_header  = headers{1};
for ii=2:length(headers)
    str_pattern = [str_pattern '\t%f']; %#ok<AGROW>
    str_header  = [str_header '\t' headers{ii}]; %#ok<AGROW>
end
str_pattern = [str_pattern '\n'];
str_header = [str_header '\n'];

% Write to file
fid = fopen(filename,'w');
fprintf(fid, str_header);
fprintf(fid, str_pattern, data');
fclose(fid);


