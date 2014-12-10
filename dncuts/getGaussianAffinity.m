function A = getGaussianAffinity(im, XY_RADIUS, RGB_SIGMA)

sz = [size(im,1), size(im,2)];

% Find all pairs of pixels within a distance of XY_RADIUS
[di,dj] = ndgrid(-XY_RADIUS:XY_RADIUS, -XY_RADIUS:XY_RADIUS);
dv = (dj.^2 + di.^2) <= XY_RADIUS.^2;
di = di(dv);
dj = dj(dv);

[i,j] = ndgrid(1:size(im,1), 1:size(im,2));
i = repmat(i(:), 1, length(di));
j = repmat(j(:), 1, length(di));
i_ = bsxfun(@plus, i, di');
j_ = bsxfun(@plus, j, dj');
v = (i_ >= 1) & (i_ <= size(im,1)) & (j_ >= 1) & (j_ <= size(im,2));
pair_i = sub2ind(sz, i(v), j(v));
pair_j = sub2ind(sz, i_(v), j_(v));

% Weight each pair by the difference in RGB values, divided by RGB_SIGMA
RGB = double(reshape(im, [], size(im,3)))/RGB_SIGMA;
W = exp(-sum((RGB(pair_i,:) - RGB(pair_j,:)).^2,2));

% Construct an affinity matrix
A = sparse(pair_i, pair_j, W, prod(sz), prod(sz));