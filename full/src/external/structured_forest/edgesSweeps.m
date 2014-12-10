function edgesSweeps()
% Parameter sweeps for structured edge detector.
% 
% Running the parameter sweeps requires altering internal flags. 
% The sweeps are not well documented, use at your own discretion.
% 
% Structured Edge Detection Toolbox      Version 1.0
% Copyright 2013 Piotr Dollar.  [pdollar-at-microsoft.com]
% Please email me if you find bugs, or have suggestions or questions!
% Licensed under the MSR-LA Full Rights License [see license.txt]

% select type and location of cluster (see fevalDistr.m)
rtDir = 'D:\code\research\StructuredForest\';
pDistr={'type','local'};

% define parameter sweeps
expNms= {'MD-imWidth','MD-gtWidth','TR-nData','TR-ratioData','TR-nImgs',...
  'TR-nTrees','TR-split','TR-minChild','TR-minCount','TR-maxDepth',...
  'TR-fracFtrs','TR-nSamples','TR-nClasses','TR-discretize',...
  'FT-nCells','FT-nOrients','FT-normRad','FT-shrink','FT-grdSmooth',...
  'FT-chnSmooth','FT-simSmooth','final'};
expNms=expNms(1:end); T=5; full=3;
[opts,lgd,lbl]=createExp(rtDir,expNms,full);

% run training and testing jobs
[jobsTrn,jobsTst] = createJobs(rtDir,opts,T); N=length(expNms);
fprintf('nTrain = %i; nTest = %i\n',length(jobsTrn),length(jobsTst));
tic, s=fevalDistr('edgesTrain',jobsTrn,pDistr); assert(s==1); toc
tic, s=fevalDistr('edgesEval',jobsTst,pDistr); assert(s==1); toc

% plot results
for e=1:N, plotExps(expNms{e},opts{e},lgd{e},lbl{e},T,1); end

end

function plotExps( expNm, opts, lgd, lbl, T, type )
% get all results and display error
disp([expNm ' [' lbl ']']); N=length(lgd);
res=zeros(N,T); mNms=cell(1,N);
for e=1:N, mNms{e}=[opts(e).modelDir 'val/' opts(e).modelFnm]; end
for e=1:N, for t=1:T, r=dlmread([mNms{e} 'T' int2str2(t,2) ...
      '-eval/eval_bdry.txt']); r=r([4 7 8]); res(e,t)=r(type); end; end
stds=std(res,0,2)*100; R=mean(res,2)*100; msg=' %.2f +/- %.2f  [%s]\n';
for e=1:N, fprintf(msg,R(e),stds(e),lgd{e}); end
if(0), disp(res); disp(max(res,[],2)); end
types={'ODS','OIS','AP'}; type=types{type};
% plot sweeps (two cases for format of x labels)
figPrp = {'Units','Pixels','Position',[800 600 640 360]};
figure(1); clf; set(1,figPrp{:}); set(gca,'FontSize',24); clr=[0 .69 .94];
pPl1={'LineWidth',3,'MarkerSize',15,'Color',clr,'MarkerFaceColor',clr};
pPl2=pPl1; clr=[1 .75 0]; pPl2{6}=clr; pPl2{8}=clr; d=0;
for e=1:N, if(lgd{e}(end)=='*'), d=e; end; end; if(d), lgd{d}(end)=[]; end
plot(R,'-d',pPl1{:}); hold on; if(d),plot(d,R(d),'d',pPl2{:}); end; e=.001;
ylabel([type ' \times 100']); axis([.5 N+.5 min([R; 62])-e max([R; 72])+e])
if(isempty(lbl)), imLabel(lgd,'bottom',30,{'FontSize',24}); lgd=[]; end
if(0); xlabel(lbl); end; set(gca,'XTick',1:1:N,'XTickLabel',lgd(1:1:N));
% save plot
plDir=[opts(1).modelDir 'plots' type '/']; fFig=[plDir expNm];
if(~exist(plDir,'dir')), mkdir(plDir); end %#ok<*CTCH>
for t=1:25, try savefig(fFig,1,'png'); break; catch, pause(1), end; end
end

function [jobsTrn,jobsTst] = createJobs( rtDir, opts, T )
% Prepare all jobs (one train and one test job per set of opts).
opts=[opts{:}]; N=length(opts); NT=N*T;
opts=repmat(opts,1,T); nms=cell(1,NT);
jobsTrn=cell(1,NT); doneTrn=zeros(1,NT);
jobsTst=cell(1,NT); doneTst=zeros(1,NT);
pTest={'dataType','val', 'nThresh',10, 'cleanup',1, ...
  'modelDir',[rtDir '/sweeps/'], 'bsdsDir',[rtDir '/BSR/BSDS500/data/']};
for e=1:NT
  t=ceil(e/N); opts(e).seed=(t-1)*100000+1;
  nm=[opts(e).modelFnm 'T' int2str2(t,2)]; opts(e).modelFnm=nm;
  mFnm=[opts(e).modelDir 'forest/' nm '.mat']; nms{e}=nm;
  eFnm=[opts(e).modelDir 'val/' nm '-eval/eval_bdry.txt'];
  doneTrn(e)=exist(mFnm,'file')==2; jobsTrn{e}={opts(e)};
  doneTst(e)=exist(eFnm,'file')==2; jobsTst{e}=[mFnm pTest];
end
[~,kp]=unique(nms,'stable');
doneTrn=doneTrn(kp); jobsTrn=jobsTrn(kp); jobsTrn=jobsTrn(~doneTrn);
doneTst=doneTst(kp); jobsTst=jobsTst(kp); jobsTst=jobsTst(~doneTst);
end

function [opts,lgd,lbl] = createExp( rtDir, expNm, full )

% if expNm is a cell, call recursively and return
if( iscell(expNm) )
  N=length(expNm); opts=cell(1,N); lgd=opts; lbl=opts;
  for e=1:N, [opts{e},lgd{e},lbl{e}]=createExp(rtDir,expNm{e},full); end
  return;
end

% default params for edgesTrain.m
opts=edgesTrain(); opts.nThreads=1; opts.nImgs=200;
opts.nTrees=4; opts.nTreesEval=2; opts.nPos=5e4; opts.nNeg=5e4;
opts.modelDir = [rtDir '/sweeps/'];
opts.bsdsDir = [rtDir '/BSR/BSDS500/data/'];

% setup opts
optsDefault=opts; N=100; lgd=cell(1,N); ss=lgd;
opts=opts(ones(1,N)); hasDefault=1;
switch expNm
  case 'MD-imWidth'
    lbl='window size for x'; vs=2.^(3:6); N=length(vs);
    for e=1:N, opts(e).imWidth=vs(e); end
    for e=1:N, opts(e).gtWidth=min(vs(e),opts(e).gtWidth); end
  case 'MD-gtWidth'
    lbl='window size for y'; vs=2.^(2:5); N=length(vs);
    for e=1:N, opts(e).gtWidth=vs(e); end
  case 'TR-nData'
    lbl='# train patches x 10^4'; vs=[1 2 5 10 20 50]; N=length(vs);
    for e=1:N, opts(e).nPos=vs(e)*1e4/2; opts(e).nNeg=vs(e)*1e4/2; end
    if(full<2), N=4; end
  case 'TR-ratioData'
    lbl = 'ratio data pos:neg'; vs=2.^((-2:2)/2); N=length(vs);
    for e=1:N, opts(e).nPos=round(5e4/vs(e)); end
    for e=1:N, opts(e).nNeg=round(5e4*vs(e)); end
    for e=1:N, lgd{e}=sprintf('%i:4',round(4./vs(e).^2)); end
    vs=round(vs*1000);
  case 'TR-nImgs'
    lbl='# train images'; vs=[10 20 50 100 200]; N=length(vs);
    for e=1:N, opts(e).nImgs=vs(e); end
  case 'TR-nTrees'
    lbl='# decision trees'; vs=2.^(0:4); N=length(vs);
    for e=1:N, opts(e).nTrees=vs(e); end;
    for e=1:N, opts(e).nTreesEval=max(1,vs(e)/2); end
    if(full<2), N=3; end
  case 'TR-split'
    lbl='information gain';
    ss={'gini','entropy','twoing'}; N=length(ss); lgd=ss;
    for e=1:N, opts(e).split=ss{e}; end
  case 'TR-minChild'
    lbl='min samples per node'; vs=1:16; N=length(vs);
    if(full<1), vs=vs(2:2:end); N=length(vs); end
    for e=1:N, opts(e).minChild=vs(e); end
  case 'TR-minCount'
    lbl='min samples for split'; vs=[1:8 10:2:14 16:8:96]; N=length(vs);
    if(full<1), vs=40; N=1; end
    for e=1:N, opts(e).minCount=vs(e); end
    for e=1:N, opts(e).minChild=1; end; hasDefault=0;
  case 'TR-maxDepth'
    lbl='max tree depth'; vs=2.^(2:6); N=length(vs);
    for e=1:N, opts(e).maxDepth=vs(e); end
  case 'TR-fracFtrs'
    lbl='fraction features'; vs=2.^(1:5); N=length(vs);
    for e=1:N, opts(e).fracFtrs=1/vs(e); end
    for e=1:N, lgd{e}=sprintf('1/%i',vs(e)); end
  case 'TR-nSamples'
    lbl='m (size of Z)'; vs=2.^(0:2:8); N=length(vs);
    for e=1:N, opts(e).nSamples=vs(e); end
  case 'TR-nClasses'
    lbl='k (size of C)'; vs=2.^(1:5); N=length(vs);
    for e=1:N, opts(e).nClasses=vs(e); end
  case 'TR-discretize'
    lbl='discretization type';
    ss={'pca','kmeans'}; N=length(ss); lgd=ss;
    for e=1:N, opts(e).discretize=ss{e}; end
  case 'FT-nCells'
    lbl='# grid cells'; vs=1:2:7; N=length(vs);
    for e=1:N, opts(e).nCells=vs(e); end
  case 'FT-nOrients'
    lbl='# gradient orients'; vs=0:2:8; N=length(vs);
    for e=1:N, opts(e).nOrients=vs(e); end
  case 'FT-normRad'
    lbl='normalization radius'; vs=[0 2.^(0:3)]; N=length(vs);
    for e=1:N, opts(e).normRad=vs(e); end
  case 'FT-shrink'
    lbl='channel downsample'; vs=2.^(0:2); N=length(vs);
    for e=1:N, opts(e).shrink=vs(e); end
  case 'FT-grdSmooth'
    lbl = 'gradient blur'; vs=[0 2.^(0:4)]; N=length(vs);
    for e=1:N, opts(e).grdSmooth=vs(e); end
  case 'FT-chnSmooth'
    lbl='channel blur'; vs=[0 2.^(0:4)]; N=length(vs);
    for e=1:N, opts(e).chnSmooth=vs(e); end
  case 'FT-simSmooth'
    lbl='self-similarity blur'; vs=[0 2.^(0:4)]; N=length(vs);
    for e=1:N, opts(e).simSmooth=vs(e); end
  case 'final'
    lbl='final'; vs=[0 1]; N=length(vs);
    for e=2:N, opts(e).nTrees=8; opts(e).nTreesEval=4; end
    for e=2:N, opts(e).nPos=5e5; opts(e).nNeg=5e5; end
    if(full<3), N=1; end
  otherwise, error('invalid exp: %s',expNm);
end

% produce final set of opts and find default opts
for e=1:N, if(isempty(lgd{e})), lgd{e}=int2str(vs(e)); end; end
for e=1:N, if(isempty(ss{e})), ss{e}=int2str2(vs(e),5); end; end
O=1:N; opts=opts(O); lgd=lgd(O); ss=ss(O); d=0;
for e=1:N, if(isequal(optsDefault,opts(e))), d=e; break; end; end
if(hasDefault && d==0), disp(expNm); assert(false); end
for e=1:N, opts(e).modelFnm=[expNm ss{e}]; end
if(hasDefault), lgd{d}=[lgd{d} '*']; opts(d).modelFnm='Default'; end
if(0), disp([ss' lgd']'); end

end
