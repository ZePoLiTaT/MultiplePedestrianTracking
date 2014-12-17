%clear all, clc, close all

vid_id = 1;

%-----------------------------------------------------------------
% FILE NAMES
%-----------------------------------------------------------------
%folder = 'NTOneLeaveShop1';
folder = 'NTOneLeaveShop1TM';
folder = sprintf('../../data/%s/',folder);

% Images
gt_corimg_file = strcat( folder, 'cor.jpg' );
gt_froimg_file = strcat( folder, 'front.jpg' );

% Ground Truth for all
gt_cor_file = strcat( folder, 'tracks_cor_fro.mat' );

% Naive Tracker
nt_cor_file = strcat( folder, 'NTracks_cor.txt' );
nt_fro_file = strcat( folder, 'NTracks_front.txt' );


% % ----> 0. Ground Truth for all
% gt_cor_file = sprintf('../../data/tracks%d_cor_fro.mat',vid_id);
% 
% % ----> 1. Corridor
% % Image
% gt_corimg_file = sprintf('../../data/OneLeaveShop%dcor0000.jpg',vid_id);
% 
% % Naive Tracker
% nt_cor_file = sprintf('../../data/OneLeaveShop%dcor_NTracks.txt',vid_id);
% % nt_cor_file = sprintf('../../data/shop%d_zntmod_cor_out.txt',vid_id);
% 
% % ----> 2. Front
% % Image
% gt_froimg_file = sprintf('../../data/OneLeaveShop%dfront0000.jpg',vid_id);
% 
% % Naive Tracker
% nt_fro_file = sprintf('../../data/OneLeaveShop%dfront_NTracks.txt',vid_id);

%-----------------------------------------------------------------
% PROCESS
%-----------------------------------------------------------------
load(gt_cor_file);

% 1. Corridor sequence
process_sequenc( nt_cor_file, tracks_cor, gt_corimg_file );

% 2. Front sequence
process_sequenc( nt_fro_file, tracks_fro, gt_froimg_file );


% % Front image
% figure(81);imshow(imread(gt_froimg_file));
% hold on, plot(tracks_fro(:,:,1),tracks_fro(:,:,2),'.');
% 
% lbl = [1:length(tracks_fro(1,:,1))]';
% lbl = cellstr(num2str(lbl))';
% lbl = strtrim(lbl);
% legend( lbl )