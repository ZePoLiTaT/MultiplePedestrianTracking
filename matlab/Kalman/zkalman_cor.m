clc; clear; close all;
%addpath(genpath('.'))

%--------------------------------------------------------------------------
%   TEST SELECTION
%--------------------------------------------------------------------------
%folder = '';
%folder = '/OneLeaveShop1';

% Template Matching Detector
folder = '/NTOneLeaveShop1TM';

% ground plane image
gp_img_file = sprintf('../../data%s/OneLeaveShop1cor0100.jpg',folder);
gp_img = imread(gp_img_file);

% Id's correspondences
%gt_id_cor = 6; nt_id_cor = 2;      % cor1: Person 1

% Template Matching Detector
gt_id_cor = 6; nt_id_cor = 6;      % cor1: Person 1

% ----> 1. Naive tracker detections
nt_cor_file = sprintf('../../data%s/NTracks_cor.txt',folder);

% ----> 2. Ground truth
gt_cor_file = sprintf('../../data%s/tracks_cor_fro.mat',folder);
load(gt_cor_file);

ss = 4; % state size
os = 2; % observation size
THRS_F = 5;

%--------------------------------------------------------------------------
%   CORRIDOR
%--------------------------------------------------------------------------
[gt_pos_cor, nt_pos_cor, first_det_frame_cor, last_det_frame_cor] = ...
    load_naive_tracks(nt_cor_file, tracks_cor, nt_id_cor, gt_id_cor );

%% Initialise the observations by drawing random observations from each
% sensor. 
sensor2.obs = nt_pos_cor;
sensor2.gt = gt_pos_cor;

%% Determine the number of iterations
INIT = first_det_frame_cor;
END = last_det_frame_cor;
N_OBSV = END-INIT;

%% Initialise some Kalman Filtering parameters
ss = 4; % state size
os = 2; % observation size
F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];  % Transition model
P1 = eye(ss)*0.1; % Posterior error covariance for tracker 1
P2 = eye(ss)*0.1; % Posterior error covariance for tracker 2
Q = 0.1*eye(ss); % Process noise covariance (single target so the same for both trackers)
H = [1 0 0 0; 0 1 0 0]; % Observation model
R = 1*eye(os); % Measurement (observation) covariance

pred2 = [sensor2.obs(:,first_det_frame_cor); 0; 0]; % prior for tracker 2


%% Initialise other variables up front for efficiency
sensor2.predictions = zeros(size(sensor2.obs));

for t=INIT:END
    % ---------------------------------------------------------------------
    % Sensor 2
    % ---------------------------------------------------------------------
    pred2 = kalman_predict(F, pred2);

    % only update if there are observations
    if all(sensor2.obs(:,t) ~= -1 )
        [ pred2, P2, prob2] = kalman_update(sensor2.obs(:,t), H, pred2, Q, R, F, P2);
    else
        prob2 = 0;    
    end

    sensor2.predictions(:,t) = pred2(1:2);
end

% Plot the results
figure(2); plot_kalman_filter( sensor2.gt, sensor2.obs, sensor2.predictions, gp_img )

[ mse ] = calculate_mse( sensor2.predictions, {sensor2.gt} )

% Calculate the MSE
% ix_gt_zeros = all(sensor2.gt~=0);
% ix_nt_zeros = all(sensor2.obs~=(-1));
% 
% dnt = sensor2.gt([1 2],:) - sensor2.obs([1 2],:);
% dnt = dnt( :, ix_gt_zeros & ix_nt_zeros );
% mse_dnt = sqrt(sum(sum(dnt.^2))) / size(dnt,2)
% 
% dfilt = sensor2.gt([1 2],:) - sensor2.predictions([1 2],:);
% dfilt = dfilt( :, ix_gt_zeros & ix_nt_zeros   );
% mse_filt = sqrt(sum(sum(dfilt.^2))) / size(dfilt,2)

