clear all, clc, close all

vid_id = 2;

% NT file names
nt_cor_file = sprintf('../../data/shop%d_zntmod_cor_out.txt',vid_id);

% GT file names
gt_corimg_file = sprintf('../../data/OneLeaveShop%dcor0000.jpg',vid_id);
gt_cor_file = sprintf('../../data/tracks%d_cor_fro.mat',vid_id);

gt_froimg_file = sprintf('../../data/OneLeaveShop%dfront0000.jpg',vid_id);


% 
% % Read the naive tracker data
% naive_tracker = csvread(nt_cor_file);
% nt_frames = naive_tracker(end,1) + 1;
% nt_ppl = max(naive_tracker(:,2)) + 1;
% naive_tracker(:,7) = naive_tracker(:,3) + naive_tracker(:,5)/2;
% naive_tracker(:,8) = naive_tracker(:,4) + naive_tracker(:,6)/2;
% 
% cmap = hsv(nt_ppl);
% figure(90), imshow(imread(gt_corimg_file));
% for i=0:nt_ppl-1
%     track_ix = find(naive_tracker(:,2)==i);
%     hold on, plot(naive_tracker(track_ix,7),naive_tracker(track_ix,8),'.','Color',cmap(i+1,:));
%     %hold on, text(100+20*i,245,num2str(i), 'Color',cmap(i+1,:));
%     %pause
% end
% 
% lbl = ( [1:nt_ppl] - 1 )';  %zero based index from c++
% lbl = cellstr(num2str(lbl))';
% lbl = strtrim(lbl);
% legend( lbl )
% 
% pause

%-----------------------------------------------------------------
% GROUND TRUTH
%-----------------------------------------------------------------
load(gt_cor_file);

% Corridor image
figure(80);imshow(imread(gt_corimg_file));
hold on, plot(tracks_cor(:,:,1),tracks_cor(:,:,2),'.');

lbl = [1:length(tracks_cor(1,:,1))]';
lbl = cellstr(num2str(lbl))';
lbl = strtrim(lbl);
legend( lbl )

% Front image
figure(81);imshow(imread(gt_froimg_file));
hold on, plot(tracks_fro(:,:,1),tracks_fro(:,:,2),'.');

lbl = [1:length(tracks_fro(1,:,1))]';
lbl = cellstr(num2str(lbl))';
lbl = strtrim(lbl);
legend( lbl )