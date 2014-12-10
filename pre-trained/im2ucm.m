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
% This function computes the MCG UCM (Ultrametric Contour Map) given an image.
%  INPUT:
%  - image : Input image
%  - mode  : It can be: + 'fast'     (SCG in the paper)
%                       + 'accurate' (MCG in the paper)
%
%  OUTPUT:
%  - ucm2       : Ultrametric Contour Map from which the candidates are
%                 extracted
%
%  DEMO:
%  - See demos/demo_im2ucm.m
% 
%  NOTE:
%  - If you are also going to compute the candidates, you can reuse the
%    UCM returned by im2mcg
% ------------------------------------------------------------------------
function ucm2 = im2ucm(image,mode)
if nargin<2
    mode = 'fast';
end

% Load pre-trained Structured Forest model
sf_model = loadvar(fullfile(root_dir, 'datasets', 'models', 'sf_modelFinal.mat'),'model');

if strcmp(mode,'fast')
    % Which scales to work on (MCG is [2, 1, 0.5], SCG is just [1])
    scales = 1;

    % Get the hierarchies at each scale and the global hierarchy
    ucm2 = img2ucms(image, sf_model, scales);

elseif strcmp(mode,'accurate')
    % Which scales to work on (MCG is [2, 1, 0.5], SCG is just [1])
    scales = [2, 1, 0.5];

    % Get the hierarchies at each scale and the global hierarchy
    ucm2 = img2ucms(image, sf_model, scales);
else
    error('Unknown mode for MCG: Possibilities are ''fast'' or ''accurate''')
end
