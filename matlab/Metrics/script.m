clc, clear,
folder = 'NTOneLeaveShop1';
folder = sprintf('../../data/%s/',folder);

%DPM
% gt_id_cor = 6; nt_id_cor = 6;      % cor1: Person 1
% % gt_id_cor = 2; nt_id_cor = 2;      % cor1: Person 2
% % gt_id_cor = 4; nt_id_cor = 0;      % cor1: Person 3
% % gt_id_cor = 5; nt_id_cor = 9;      % cor1: Person 4
% 
% gt_id_fro = 2; nt_id_fro = 1;      % fro1: Person 1

%HOG
% gt_id_cor = 6; nt_id_cor = 2;      % cor1: Person 1
% %gt_id_cor = 2; nt_id_cor = 4;      % cor1: Person 2
% %gt_id_cor = 5; nt_id_cor = 1;      % cor1: Person 4
% 
% gt_id_fro = 2; nt_id_fro = 2;      % fro1: Person 1


% ----> 1. Naive tracker detections
nt_cor_file = strcat(folder, 'NTracks_cor.txt');
nt_fro_file = strcat(folder, 'NTracks_front.txt');

% ----> 2. Ground truth
gt_cor_file = strcat(folder, 'tracks_cor_fro.mat');
%gt_fro_file = strcat(folder, 'tracks_cor_fro.mat');

load(gt_cor_file);
%load(gt_fro_file);

% - cor

[gt, nt, first_det_frame, last_det_frame] = ...
    load_naive_tracks(nt_cor_file, tracks_cor, nt_id_cor, gt_id_cor );

[ tp, fp,fn ] = stats_metrics( gt, nt )

% statistics
disp('cor');
sensitivity = tp / (tp + fn)
precision = tp / (tp + fp)

% - fro
% 
% 
% [gt, nt, first_det_frame, last_det_frame] = ...
%     load_naive_tracks(nt_fro_file, tracks_fro, nt_id_fro, gt_id_fro );
% 
% [ tp, fp, fn ] = stats_metrics( gt, nt )
% 
% % statistics
% disp('fro');
% sensitivity = tp / (tp + fn)
% precision = tp / (tp + fp)

