function [J, inters, fp, fn] = jaccard( object, ground_truth, valid_pixels )
%[J, inters, fp, fn] = jaccard( object, ground_truth, valid_pixels )
% ------------------------------------------------------------------------
% Calculates the Jaccard index (overlap, intersection over union) between two masks
%
% INPUT
%         object      Object mask.
%   ground_truth      Ground-truth mask.
%   valid_pixels      [Optional] Mask of the pixels we consider as valid 
%                      (for instance in Pascal ground truths, the pixels <255).
%                      If no mask is set, all pixels are valid
%
% OUTPUT
%              J       Jaccard index
%         inters       Mask of the interesection between the two masks
%             fp       Mask of the false positives
%             fn       Mask of the false negatives
%
% ------------------------------------------------------------------------
%  Copyright (C)
%  Universitat Politecnica de Catalunya BarcelonaTech (UPC) - Spain
%
%  Jordi Pont <jordi.pont@upc.edu>
%  March 2011
% ------------------------------------------------------------------------

object = logical(object);
ground_truth = logical(ground_truth);

if nargin<3
    valid_pixels = ones(size(ground_truth));
else
    valid_pixels = logical(valid_pixels);
end

inters = object.*ground_truth.*valid_pixels;
fp = object.*(1-inters).*valid_pixels;
fn = ground_truth.*(1-inters).*valid_pixels;

denom = sum(inters(:)) + sum(fp(:)) + sum(fn(:));
if denom==0
    J = 0;
else
    J =  sum(inters(:))/denom;
end
