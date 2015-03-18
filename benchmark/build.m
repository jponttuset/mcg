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
%
% This function builds all the MEX files needed.
% Dependencies: Boost C++ libraries (http://www.boost.org)
%
% The code contains C++11 functionality, so you have to use a compiler that
% supports the flag -std=c++11.
% Some help on how to do it in: http://jponttuset.github.io/matlab2014-mex-flags/
% ------------------------------------------------------------------------

function build()
%% Check that root_dir is set properly
if ~exist(root_dir,'dir')
    error('Error building the package, try updating the value of root_dir in the file "root_dir.m"')
end

%% Include the generic paths and files to compile
include{1} = fullfile(root_dir, 'src', 'aux');  % To get matlab_multiarray.hpp
if (strcmp(computer(),'PCWIN64') || strcmp(computer(),'PCWIN32'))
    include{2} = 'C:\Program Files\boost_1_55_0';  % Boost libraries (change it if necessary)
else
    include{2} = '/opt/local/include/';  % Boost libraries (change it if necessary)
end

include_str = '';
for ii=1:length(include)
    include_str = [include_str ' -I''' include{ii} '''']; %#ok<AGROW>
end

build_file{1} = fullfile(root_dir, 'src', 'segmented', 'mex_eval_labels.cpp');
build_file{2} = fullfile(root_dir, 'src', 'segmented', 'mex_eval_masks.cpp');
build_file{3} = fullfile(root_dir, 'src', 'segmented', 'mex_eval_blobs.cpp');


%% Build everything
if ~exist(fullfile(root_dir, 'lib'),'dir')
    mkdir(fullfile(root_dir, 'lib'))
end
            
for ii=1:length(build_file)
    eval(['mex ''' build_file{ii} ''' -outdir ''' fullfile(root_dir, 'lib') '''' include_str])
end

%% Build COCO
eval(['mex src/coco/private/gasonMex.cpp src/coco/private/gason.cpp -Isrc/coco/private -I/usr/local/include -outdir ''' fullfile(root_dir, 'lib') '''' include_str])

%% Clear variables
clear build_file ii include include_str

%% Show message
disp('-- Successful compilation of MCG. Enjoy! --')
