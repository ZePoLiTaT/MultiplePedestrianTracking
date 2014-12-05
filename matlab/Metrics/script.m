vid_id = 1;

seq = 'cor';
%seq = 'front';

%folder = '/gplane';
folder = '';

% Id's correspondences
%gt_id = 6; nt_id = 2;     % cor1: Person 1
%gt_id = 2; nt_id = 2;      % fro1: Person 1

%gt_id = 1; nt_id = 2;      % cor2: Person 1
%gt_id = 5; nt_id = 11;     % cor2: Person 2

% ----> 1. Naive tracker detections
nt_cor_file = sprintf('../../data%s/OneLeaveShop%d%s_NTracks.txt',folder,vid_id,seq);

% ----> 2. Ground truth
gt_cor_file = sprintf('../../data%s/tracks%d_cor_fro.mat',folder,vid_id);
load(gt_cor_file);

if strcmp(seq, 'cor')
    tracks = tracks_cor;
    if vid_id == 1
        gt_id = 6; nt_id = 2;       % cor1: Person 1
    else
        gt_id = 1; nt_id = 2;       % cor2: Person 1
        %gt_id = 5; nt_id = 11;     % cor2: Person 2
    end
else
    tracks = tracks_fro;
    
    if vid_id == 1
        gt_id = 2; nt_id = 2;      % fro1: Person 1
    end    
end

[gt, nt, first_det_frame, last_det_frame] = ...
    load_naive_tracks(nt_cor_file, tracks, nt_id, gt_id );

[ tp, fp,fn ] = stats_metrics( gt, nt )