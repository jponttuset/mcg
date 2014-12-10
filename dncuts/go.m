
clear all;

XY_RADIUS = 7; % look at all pairs of pixels in this radius
RGB_SIGMA = 30; % Divide RGB differences between pixels by this
NVEC = 16; % How many eigenvectors (with non-zero eigenvalues) we want to produce

DNCUTS_N_DOWNSAMPLE = 2; % the number of times we decimate in DNcuts, values between 1 and 3 are usually good
DNCUTS_DECIMATE = 2; % the amount of decimation at each level of DNcuts, should probably be between 2, but [2:4] works sometimes


tic;
% Load in an image
im = imresize(imread('lena.bmp'), [256,256]);
sz = [size(im,1), size(im,2)];
time_load_image = toc

tic;
% Construct a really simple affinity measure between pixels. This is just a
% dumb and slow version of something good like PB+intervening contour.
A = getGaussianAffinity(im, XY_RADIUS, RGB_SIGMA);
time_construct_affinity = toc

% Do normalized cuts our new, fast way
tic;
[EV_fast, EVal_fast] = dncuts(A, NVEC, DNCUTS_N_DOWNSAMPLE, DNCUTS_DECIMATE, sz);
time_dncuts = toc

% Do normalized cuts the old way
tic;
[EV_true, EVal_true] = ncuts(A, NVEC);
time_ncuts = toc

fprintf('DNcuts is %0.1fx faster!\n', time_ncuts / time_dncuts)

% For visualization, let's reorder the fast eigenvectors to match up with
% the true ones, to get rid of mismatches due to eigenvalues being
% mis-estimated. This is surprisingly annoying to do
C = abs(EV_fast' * EV_true);
M = 1:size(C,1);
for pass = 1:10
  M_last = M;
  for i = 1:size(C,1)
    for j = (i+1):size(C,1)
      
      if (C(i,M(j)) + C(j,M(i))) > (C(i,M(i)) + C(j,M(j)))
        m = M(j);
        M(j) = M(i);
        M(i) = m;
      end
      
    end
  end
  if all(M == M_last)
    break
  end
end

[junk, M] = ismember(1:NVEC, M);
EV_fast = EV_fast(:,M);


% Let's flip the signs of the fast eigenvectors to match the true ones, as
% the sign is arbitrary
EV_fast = bsxfun(@times, EV_fast, sign(sum(EV_fast .* EV_true)));

C = EV_fast' * EV_true;
accuracy = trace(C) / NVEC % the closer the trace of C is to NVEC, the better the approximation


% The eigenvectors usually look very similar, let's visualize them
vis_true = reshape(EV_true, size(im,1), size(im,2), 1, NVEC);
vis_fast = reshape(EV_fast, size(im,1), size(im,2), 1, NVEC);

vis_true = 4 * sign(vis_true) .* abs(vis_true).^0.5;
vis_fast = 4 * sign(vis_fast) .* abs(vis_fast).^0.5;

figure; montage(max(0, min(1, vis_true + 0.5))); colormap(betterjet); title('true eigenvectors');
figure; montage(max(0, min(1, vis_fast + 0.5))); colormap(betterjet); title('fast approximate eigenvectors');


% For fun, let's project the image into and out of the eigenvectors and
% visualize it
X = double(reshape(im, [], 3));
mu = mean(X,1);
Xc = bsxfun(@minus, X, mu);
im_eig = uint8(reshape(bsxfun(@plus, EV_fast * (Xc' * EV_fast)', mu), size(im)));
figure; imagesc([im, im_eig]); axis image off;

