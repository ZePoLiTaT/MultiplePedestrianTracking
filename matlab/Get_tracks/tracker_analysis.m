%clear all, clc, close all

vid_id = 1;

%-----------------------------------------------------------------
% FILE NAMES
%-----------------------------------------------------------------

% ----> 0. Ground Truth for all
gt_cor_file = sprintf('../../data/tracks%d_cor_fro.mat',vid_id);

% ----> 1. Corridor
% Image
gt_corimg_file = sprintf('../../data/OneLeaveShop%dcor0000.jpg',vid_id);

% Naive Tracker
nt_cor_file = sprintf('../../data/OneLeaveShop%dcor_NTracks.txt',vid_id);
% nt_cor_file = sprintf('../../data/shop%d_zntmod_cor_out.txt',vid_id);

% ----> 2. Front
% Image
gt_froimg_file = sprintf('../../data/OneLeaveShop%dfront0000.jpg',vid_id);

% Naive Tracker
nt_fro_file = sprintf('../../data/OneLeaveShop%dfront_NTracks.txt',vid_id);

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