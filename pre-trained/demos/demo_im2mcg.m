
%% Demo to show the results of MCG
clear all;close all;home;

% Read an input image
I = imread(fullfile(mcg_root, 'demos','101087.jpg'));

tic;
% Test the 'fast' version, which takes around 5 seconds in mean
[candidates_scg, ucm2_scg] = im2mcg(I,'fast');
toc;

tic;
% Test the 'accurate' version, which tackes around 20 seconds in mean
[candidates_mcg, ucm2_mcg] = im2mcg(I,'accurate');
toc;

%% Show UCM results (dilated for visualization)
figure;
subplot(1,3,1)
imshow(I), title('Image')

subplot(1,3,2)
imshow(imdilate(ucm2_scg,strel(ones(3))),[]), title('Fast UCM (SCG)')

subplot(1,3,3)
imshow(imdilate(ucm2_mcg,strel(ones(3))),[]), title('Accurate UCM (MCG)')


%% Show Object Candidates results and bounding boxes
% Candidates in rank position 11 and 12
id1 = 11; id2 = 12;

% Get the masks from superpixels and labels
mask1 = ismember(candidates_mcg.superpixels, candidates_mcg.labels{id1});
mask2 = ismember(candidates_mcg.superpixels, candidates_mcg.labels{id2});

% Bboxes is a matrix that contains the four coordinates of the bounding box
% of each candidate in the form [up,left,down,right]. See folder bboxes for
% more function to work with them

% Show results
figure;
subplot(1,3,1)
imshow(I), title('Image')
subplot(1,3,2)
imshow(mask1), title('Candidate + Box')
hold on
plot([candidates_mcg.bboxes(id1,4) candidates_mcg.bboxes(id1,4) candidates_mcg.bboxes(id1,2) candidates_mcg.bboxes(id1,2) candidates_mcg.bboxes(id1,4)],...
     [candidates_mcg.bboxes(id1,3) candidates_mcg.bboxes(id1,1) candidates_mcg.bboxes(id1,1) candidates_mcg.bboxes(id1,3) candidates_mcg.bboxes(id1,3)],'r-')
subplot(1,3,3)
imshow(mask2), title('Candidate + Box')
hold on
plot([candidates_mcg.bboxes(id2,4) candidates_mcg.bboxes(id2,4) candidates_mcg.bboxes(id2,2) candidates_mcg.bboxes(id2,2) candidates_mcg.bboxes(id2,4)],...
     [candidates_mcg.bboxes(id2,3) candidates_mcg.bboxes(id2,1) candidates_mcg.bboxes(id2,1) candidates_mcg.bboxes(id2,3) candidates_mcg.bboxes(id2,3)],'r-')
