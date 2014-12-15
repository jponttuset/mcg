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
% Test reproducibility of the code
% ------------------------------------------------------------------------

% Read an input image
I = imread(fullfile(mcg_root, 'demos','101087.jpg'));

% Compute SCG twice
candidates_scg1 = im2mcg(I,'fast');
candidates_scg2 = im2mcg(I,'fast');

eq_scg = isequal(candidates_scg1,candidates_scg2);

candidates_mcg1 = im2mcg(I,'accurate');
candidates_mcg2 = im2mcg(I,'accurate');

eq_mcg = isequal(candidates_mcg1,candidates_mcg2);

if eq_scg && eq_mcg
    disp('OK: Reproducibility tests passed')
else
    disp('ERROR: Reproducibility tests not passed!!')
end

