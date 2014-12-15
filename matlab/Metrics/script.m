folder = 'NTOneLeaveShop1TM';
folder = sprintf('../../data/%s/',folder);

% ground plane image
%gp_img_file = strcat(folder, 'gp.png');
%gp_img = imread(gp_img_file);

% Id's correspondences
gt_id_cor = 6; nt_id_cor = 6;      % cor1: Person 1
gt_id_fro = 2; nt_id_fro = 1;      % fro1: Person 1

%gt_id = 1; nt_id = 2;      % cor2: Person 1
%gt_id = 5; nt_id = 11;     % cor2: Person 2

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

% - fro

disp('fro');

[gt, nt, first_det_frame, last_det_frame] = ...
    load_naive_tracks(nt_fro_file, tracks_fro, nt_id_fro, gt_id_fro );

[ tp, fp,fn ] = stats_metrics( gt, nt )

