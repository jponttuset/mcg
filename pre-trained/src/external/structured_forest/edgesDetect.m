function [E,Es,O] = edgesDetect( I, model )
% Detect edges in image.
%
% For an introductory tutorial please see edgesDemo.m.
%
% The following model params may be altered prior to detecting edges:
%  prm = stride, multiscale, nTreesEval, nThreads, nms
% Simply alter model.opts.prm. For example, set model.opts.nms=1 to enable
% non-maximum suppression. See edgesTrain for parameter details.
%
% USAGE
%  [E,Es,O] = edgesDetect( I, model )
%
% INPUTS
%  I          - [h x w x 3] color input image
%  model      - structured edge model trained with edgesTrain
%
% OUTPUTS
%  E          - [h x w] edge probability map
%  Es         - [h x w x nEdgeBins] edge probability maps per orientation
%  O          - [h x w] coarse edge normal orientation (0=left, pi/2=up)
%
% EXAMPLE
%
% See also edgesDemo, edgesTrain, edgesChns
%
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

% get parameters
opts=model.opts; opts.nTreesEval=min(opts.nTreesEval,opts.nTrees);
opts.stride=max(opts.stride,opts.shrink); model.opts=opts;

if( opts.multiscale )
  % if multiscale run edgesDetect multiple times
  ss=2.^(-1:1); k=length(ss); siz=size(I);
  model.opts.multiscale=0; model.opts.nms=0; Es=0;
  for i=1:k, s=ss(i); I1=imResample(I,s);
    [~,Es1]=edgesDetect(I1,model);
    Es=Es+imResample(Es1,siz(1:2));
  end; Es=Es/k;
  
else
  % pad image, making divisible by 4
  sizOrig=size(I); r=opts.imWidth/2; p=[r r r r];
  p([2 4])=p([2 4])+mod(4-mod(sizOrig(1:2)+2*r,4),4);
  I = imPad(I,p,'symmetric');
  
  % compute features and apply forest to image
  [chnsReg,chnsSim] = edgesChns( I, opts );
  Es = edgesDetectMex(model,chnsReg,chnsSim);
  
  % normalize and finalize edge maps
  t=2*opts.stride^2/opts.gtWidth^2/opts.nTreesEval; r=opts.gtWidth/2;
  O=[]; Es=Es(1+r:sizOrig(1)+r,1+r:sizOrig(2)+r,:)*t; Es=convTri(Es,1);
end

% compute E and O and perform nms
nEdgeBins=opts.nEdgeBins; if(nEdgeBins>1), E=sum(Es,3); else E=Es; end
if(nargout>2 || opts.nms), if(nEdgeBins<=2), O=edgeOrient(E,4); else
    [~,O]=max(Es,[],3); O=single(O-1)*(pi/nEdgeBins); end; end
if(opts.nms), E=edgeNms(E,O,1,5); end

end

function E = edgeNms( E, O, r, s )
% suppress locations where edge is stronger in orthogonal direction
E1=imPad(E,r+1,'replicate'); Dx=cos(O); Dy=sin(O);
[ht,wd]=size(E1); [cs,rs]=meshgrid(r+2:wd-r-1,r+2:ht-r-1);
for i=-r:r, if(i==0), continue; end
  cs0=i*Dx+cs; dcs=cs0-floor(cs0); cs0=floor(cs0);
  rs0=i*Dy+rs; drs=rs0-floor(rs0); rs0=floor(rs0);
  E2 = (1-dcs).*(1-drs) .* E1(rs0+0+(cs0-1)*ht);
  E2 = E2 + dcs.*(1-drs) .* E1(rs0+0+(cs0-0)*ht);
  E2 = E2 + (1-dcs).*drs .* E1(rs0+1+(cs0-1)*ht);
  E2 = E2 + dcs.*drs .* E1(rs0+1+(cs0-0)*ht);
  E(E*1.01<E2) = 0;
end
% suppress noisy estimates near boundaries
for r=1:s, E([r end-r+1],:,:)=E([r end-r+1],:,:)*(r-1)/s; end
for r=1:s, E(:,[r end-r+1],:)=E(:,[r end-r+1],:)*(r-1)/s; end
end

function O = edgeOrient( E, r )
% compute very approximate orientation map from edge map
E2=convTri(E,r); f=[-1 2 -1];
Dx=conv2(E2,f,'same'); Dy=conv2(E2,f','same');
F=conv2(E2,[1 0 -1; 0 0 0; -1 0 1],'same')>0;
Dy(F)=-Dy(F); O=mod(atan2(Dy,Dx),pi);
end
