clc; clear; 
%close all;
%addpath(genpath('.'))

%--------------------------------------------------------------------------
%   TEST SELECTION
%--------------------------------------------------------------------------
%folder = '/GPlaneOneLeaveShop1_feet';
%folder = '';

folder = 'NTOneLeaveShop1';
folder = sprintf('../../data/%s/',folder);

% ground plane image
gp_img_file = strcat(folder, 'gp.png');
gp_img = imread(gp_img_file);

% Id's correspondences
gt_id_cor = 6; nt_id_cor = 2;      % cor1: Person 1
gt_id_fro = 2; nt_id_fro = 2;      % fro1: Person 1

%gt_id = 1; nt_id = 2;      % cor2: Person 1
%gt_id = 5; nt_id = 11;     % cor2: Person 2

% ----> 1. Naive tracker detections
nt_cor_file = strcat(folder, 'GP_NTracks_cor.txt');
nt_fro_file = strcat(folder, 'GP_NTracks_front.txt');

% ----> 2. Ground truth
gt_cor_file = strcat(folder, 'GP_tracks_cor.mat');
gt_fro_file = strcat(folder, 'GP_tracks_front.mat');

load(gt_cor_file);
load(gt_fro_file);

ss = 4; % state size
os = 2; % observation size
THRS_F = 5;

td = 77;

%--------------------------------------------------------------------------
%   FRONT
%--------------------------------------------------------------------------

[gt_pos_fro, nt_pos_fro, first_det_frame_fro, last_det_frame_fro] = ...
    load_naive_tracks(nt_fro_file, tracks_fro, nt_id_fro, gt_id_fro );

%--------------------------------------------------------------------------
%   CORRIDOR
%--------------------------------------------------------------------------
[gt_pos_cor, nt_pos_cor, first_det_frame_cor, last_det_frame_cor] = ...
    load_naive_tracks(nt_cor_file, tracks_cor, nt_id_cor, gt_id_cor );

%--------------------------------------------------------------------------
%   DATA FUUUUUU FUUU FUUU SION AHHHH
%--------------------------------------------------------------------------

%% Initialise the observations by drawing random observations from each
% sensor. 
sensor1.obs = nt_pos_fro(:,td+1:end);
sensor1.obs = [sensor1.obs, ones(2,td)*-1];
sensor2.obs = nt_pos_cor;

sensor1.gt = gt_pos_fro(:,td+1:end);
sensor1.gt = [sensor1.gt, ones(4,td)*-1];
sensor2.gt = gt_pos_cor;

%% Determine the number of iterations
% ajustar frame de acuerdo a temporal difference entre corridor y front
first_det_frame_fro = first_det_frame_fro-td;
last_det_frame_fro = last_det_frame_fro-td;

% tomar primera deteccion como posicion inicial
pred1 = [sensor1.obs(:,first_det_frame_fro); 0; 0]; % prior for tracker 1
pred2 = [sensor2.obs(:,first_det_frame_cor); 0; 0]; % prior for tracker 2
if (first_det_frame_fro < first_det_frame_cor)
    prediction = [sensor1.obs(:,first_det_frame_fro); 0; 0];
else
    prediction = [sensor2.obs(:,first_det_frame_cor); 0; 0];
end

% empezar observaciones en tiempo 2 porque la primera es la pos. inicial
first_det_frame_fro = first_det_frame_fro + 1;
first_det_frame_cor = first_det_frame_cor + 1;
INIT = min(first_det_frame_fro,first_det_frame_cor);
END = max(last_det_frame_fro,last_det_frame_cor);
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

% Initialise other variables up front for efficiency
sensor1.predictions = zeros(2,N_OBSV);
sensor2.predictions = zeros(2,N_OBSV);

%% Fusioon strategy variables
% Feature level
sensorfused.predictions = zeros(2,N_OBSV);

% Classifier output level
prob1 = 0;
prob2 = 0;

% Winner takes all
winnerTakesAll = zeros(2,N_OBSV);

% Weighted sum 
marginalsWTA = zeros(2,N_OBSV);
marginalsWS = zeros(2,N_OBSV);
marginalsSP = zeros(2,N_OBSV);

sensor1Weight = 0.5;
sensor2Weight = 1-sensor1Weight;
weightedSum = zeros(2,N_OBSV);

% Tunable parameters
usePriors = 0;
prior1 = 0;
prior2 = 0;

for t=INIT:END
    
    
    prediction = kalman_predict(F, prediction);
    observation_list = [ sensor1.obs(:,t), sensor2.obs(:,t) ];
    observation = select_feature( prediction(1:2), observation_list );
    
    if all(observation ~= -1 )
        [ prediction, P, prob] = kalman_update(sensor1.obs(:,t), H, pred1, Q, R, F, P1);
    end
    
    sensorfused.predictions(:,t) = prediction(1:2);
    
    % ---------------------------------------------------------------------
    % Prediccion KALMAN Sensor 1
    % ---------------------------------------------------------------------
    if t >= first_det_frame_fro
        
        pred1 = kalman_predict(F, pred1);
        
        % only update if there are observations
        if all(sensor1.obs(:,t) ~= -1 )
            [ pred1, P1, prob1] = kalman_update(sensor1.obs(:,t), H, pred1, Q, R, F, P1);
        else
            prob1 = 0;
        end
        
        sensor1.predictions(:,t) = pred1(1:2);
    end
    
    % ---------------------------------------------------------------------
    % Prediccion KALMAN Sensor 2
    % ---------------------------------------------------------------------
    
    if t >= first_det_frame_cor
        
        pred2 = kalman_predict(F, pred2);
        
        % only update if there are observations
        if all(sensor2.obs(:,t) ~= -1 )
            [ pred2, P2, prob2] = kalman_update(sensor2.obs(:,t), H, pred2, Q, R, F, P2);
        else
            prob2 = 0;    
        end
        
        sensor2.predictions(:,t) = pred2(1:2);

    end
    
    % ---------------------------------------------------------------------
    % Fusion Strategies
    % ---------------------------------------------------------------------
    
end

% Plot the results
figure(40); plot_kalman_filter( sensor1.gt, sensor1.obs, sensor1.predictions, gp_img )
figure(41); plot_kalman_filter( sensor2.gt, sensor2.obs, sensor2.predictions, gp_img )

% Concatenate gt and observations
fused.gt = [sensor1.gt,sensor2.gt];
fused.obs = [sensor1.obs,sensor2.obs];

figure(42); plot_kalman_filter( fused.gt, fused.obs, winnerTakesAll, gp_img )

figure(43); plot_kalman_filter( fused.gt, fused.obs, weightedSum, gp_img )

% Calculate the MSE
%[ mse_dnt_cor, mse_filt_cor ] = calculate_mse( sensor1.predictions, sensor1.gt, sensor1.obs )

% Report purposes
%addpath('../PlotUtils');
%figure(1); printimage('../../../Report/figs/KF_fus_s1');