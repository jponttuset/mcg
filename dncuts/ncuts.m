function [EV, EVal] = ncuts(A, n_ev)
% Computes the n_ev smallest (non-zero) eigenvectors and eigenvalues of the 
% of the Laplacian of A

D = sparse(1:size(A,1), 1:size(A,1), full(sum(A, 1)), size(A,1), size(A,2));

opts.issym = 0;
opts.isreal = 1;
opts.disp = 0;
nvec = n_ev+1;

[EV, EVal] = eigs((D - A) + (10^-10) * speye(size(D)), D, nvec, 'sm',opts);

[junk, sortidx] = sort(diag(EVal), 'descend');
EV = EV(:,sortidx(end-1:-1:1));
v = diag(EVal);
EVal = v(sortidx(end-1:-1:1));

EV = bsxfun(@rdivide, EV, sqrt(sum(EV.^2,1))); % makes the eigenvectors unit norm
