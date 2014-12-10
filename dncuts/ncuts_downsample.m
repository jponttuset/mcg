function EV = ncuts_downsample(A, NVEC, N_DOWNSAMPLE, DECIMATE, SZ)
% A = affinity matrix
% NEVC = number of eigenvectors (set to 16?)
% N_DOWNSAMPLE = number of downsampling operations (2 seems okay)
% DECIMATE = amount of decimation for each downsampling operation (set to 2)
% SZ = size of the image corresponding to A

A_down = A;
SZ_down = SZ;

Cs = {};
for di = 1:N_DOWNSAMPLE
  
  % Create a binary array of the pixels that will remain after decimating
  % every other row and column
  [i,j] = ind2sub(SZ_down, 1:size(A_down,1));
  do_keep = (mod(i, DECIMATE) == 0) & (mod(j, DECIMATE) == 0);

    % Downsample the affinity matrix
%   D = sparse(1:nnz(do_keep), find(do_keep), 1, nnz(do_keep), size(A_down,2));
%   B = D * A_down;
%   keyboard

  % Downsample the affinity matrix
  B = A_down(:,do_keep);
  
  Cs{di} = sparse(1:size(B,1), 1:size(B,1), 1 ./ (B * ones(size(B,2), 1) + eps)) * B; % Hold onto the normalized affinity matrix for bookkeeping

  % "Square" the affinity matrix, while downsampling
  A_down = Cs{di}'*B;
  
  SZ_down = floor(SZ_down / 2);
  
  
end

% Get the eigenvectors of the Laplacian
EV = ncuts(A_down, NVEC);

% Upsample the eigenvectors
for di = N_DOWNSAMPLE:-1:1
  EV = Cs{di} * EV;
end

% whiten the eigenvectors, as they can get scaled weirdly during upsampling
EV = orth(bsxfun(@minus, EV, mean(EV,1)));



