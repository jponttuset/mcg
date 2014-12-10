function im2ucms_all(database,gt_set)

if nargin==0
   database = 'pascal2012';
end
if nargin<2
   gt_set = 'train2012';
end

res_id = 'sf_mUCM';

% Multiple scales to work on, finest first
scales = [2, 1, 0.5];

% Result dir
res_dir = fullfile(root_dir,'datasets',database,res_id);

% Check that results dir exist
if ~exist(fullfile(res_dir,'multi'),'dir')
    mkdir(fullfile(res_dir,'multi'))
end
for ii=1:length(scales)
    if ~exist(fullfile(res_dir,['scale_',sprintf('%1.2f',scales(ii))]),'dir')
        mkdir(fullfile(res_dir,['scale_',sprintf('%1.2f',scales(ii))]))
    end
end
    
% Which images to process
im_ids = database_ids(database,gt_set);

% Load pre-trained model for contour detector
model = loadvar(fullfile(root_dir, 'datasets', 'models', 'sf_modelFinal.mat'),'model');

% Sweep all images in parallel
matlabpool(4)
parfor ii=1:length(im_ids)
    im = get_image(database,im_ids{ii});
    
    % Check if it is not computed already
    if ~exist(fullfile(res_dir,'multi',[im_ids{ii} '.mat']),'file')
        
        % Call the actual code
        [ucm2,ucms] = img2ucms(im, model, scales);

        % Store ucms at each scale separately
        parsave(fullfile(res_dir,'multi',[im_ids{ii} '.mat']),ucm2)
        for jj=1:length(scales)
            parsave(fullfile(res_dir,['scale_',sprintf('%1.2f',scales(jj))],[im_ids{ii} '.mat']),ucms(:,:,jj))
        end
    end
end
matlabpool close
end

function parsave(res_file, ucm2) %#ok<INUSD>
    save(res_file,'ucm2');
end
