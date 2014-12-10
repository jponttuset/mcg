function [X_white, params] = whiten(X, DO_CENTER, V_PAD)
% [X_white, params] = whiten(X, DO_CENTER)
% 
% Produces X_white, which is a whitened version of X, and params, which
% encodes the whitening transformation. The whitening transformation can
% be applied to arbitrary data and inverted as follows:
% 
% X_white = bsxfun(@minus, X, params.mu) * params.transform;
% X_recon = bsxfun(@plus, X_white * params.inverse, params.mu);

if nargin < 2
    DO_CENTER = 1;
end

if nargin < 3
    V_PAD = .1;
end

X = double(X);
if DO_CENTER
  params.mu = mean(X,1);
else
  params.mu = zeros(1, size(X,2));
end

X_centered = bsxfun(@minus, X, params.mu);

C = (X_centered'*X_centered);

[V,D] = eig(C);

iD = diag(sqrt(1./(diag(D) + V_PAD)));
params.transform = V * iD * V';
params.inverse = inv(params.transform);

X_white = bsxfun(@minus, X, params.mu) * params.transform;
