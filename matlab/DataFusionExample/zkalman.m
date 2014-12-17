clc; clear; 
%close all;
%addpath(genpath('.'))

%--------------------------------------------------------------------------
%   TEST SELECTION
%--------------------------------------------------------------------------
%folder = '/GPlaneOneLeaveShop1_feet';
%folder = '';

% HOG Detector
%folder = 'NTOneLeaveShop1';

% Template Matching Detector
folder = 'NTOneLeaveShop1TM';

folder = sprintf('../../data/%s/',folder);

% ground plane image
gp_img_file = strcat(folder, 'gp.png');
gp_img = imread(gp_img_file);

% ID NTOneLeaveShop1
% gt_id_cor = 6; nt_id_cor = 2;      % cor1: Person 1
% gt_id_fro = 2; nt_id_fro = 2;      % fro1: Person 1

% ID NTOneLeaveShop1NT
gt_id_cor = 6; nt_id_cor = 6;      % cor1: Person 1
gt_id_fro = 2; nt_id_fro = 1;      % fro1: Person 1

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

td = 77;
%td = 67;
TRACK_THRS = 30;

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

%% Initialise the observations by drawing random observations from each sensor. 
sensor1.obs = nt_pos_fro(:,td+1:end);
sensor1.obs = [sensor1.obs, ones(2,td)*-1];
sensor2.obs = nt_pos_cor;

%Prueba proyectando sobre GT
% sensor1.obs = gt_pos_fro(1:2,td+1:end);
% sensor1.obs = [sensor1.obs, ones(2,td)*-1];
% sensor2.obs = gt_pos_cor(1:2,:);


sensor1.gt = gt_pos_fro(:,td+1:end);
sensor1.gt = [sensor1.gt, ones(4,td)*-1];

sensor1.gt = sensor1.gt(1:2, :);
sensor2.gt = gt_pos_cor(1:2, :);

%% Determine the number of iterations
% ajustar frame de acuerdo a temporal difference entre corridor y front
first_det_frame_fro = first_det_frame_fro-td;
last_det_frame_fro = last_det_frame_fro-td;

% tomar primera deteccion como posicion inicial
pred1 = [sensor1.obs(:,first_det_frame_fro); 0; 0]; % prior for tracker 1
pred2 = [sensor2.obs(:,first_det_frame_cor); 0; 0]; % prior for tracker 2

if (first_det_frame_fro < first_det_frame_cor)
    prediction = pred1
else
    prediction = pred2
end

% y removerla de las observaciones
sensor1.obs(:,first_det_frame_fro) = [-1; -1];
sensor2.obs(:,first_det_frame_cor) = [-1; -1];

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
P = eye(ss)*0.1; % Posterior error covariance for fused tracker
Q = 0.1*eye(ss); % Process noise covariance (single target so the same for both trackers)
H = [1 0 0 0; 0 1 0 0]; % Observation model
R = 1*eye(os); % Measurement (observation) covariance

% Initialise other variables up front for efficiency
sensor1.predictions = zeros( size(sensor1.gt) );
sensor2.predictions = zeros( size(sensor2.gt) );

%% Fusioon strategy variables
fused.predictions = zeros( size(sensor1.gt) );
fused.gt = {sensor1.gt,sensor2.gt};
fused.obs = {sensor1.obs;sensor2.obs};
fused.obs2 = [sensor1.obs,sensor2.obs];

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

%figure(44); plot_kalman_filter( fused.gt, fused.obs, weightedSum, gp_img ); title('Weighted Sum')
for t=INIT:END+TRACK_THRS
    
    % ---------------------------------------------------------------------
    % Prediccion KALMAN Sensor 1
    % ---------------------------------------------------------------------
    if t >= first_det_frame_fro && t<= last_det_frame_fro + TRACK_THRS
        
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
    
    if t >= first_det_frame_cor && t<= last_det_frame_cor + TRACK_THRS
        
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
    
    % ---------------------------------------------------------------------
    %% Option 0: Feature Level
    % ---------------------------------------------------------------------
    prediction = kalman_predict(F, prediction);
    observation_list = [ sensor1.obs(:,t), sensor2.obs(:,t) ];
    observation = select_feature( prediction(1:2), observation_list );
    
    if all(observation ~= -1 )
        [ prediction, P, prob] = kalman_update(observation, H, prediction, Q, R, F, P);
    end
    
    fused.predictions(:,t) = prediction(1:2);
    
    % ---------------------------------------------------------------------
    %% Option 1: Use the 'Winner Takes All' strategy for choosing our resulting
    % ---------------------------------------------------------------------
    % prediction. 
     if t < first_det_frame_fro 
        % Before any measurment nullify the weigth for this sensor
        prior1 = 0;
     elseif t == first_det_frame_fro 
        % First observation we have no prior, so use 0.5 for each sensor
        prior1 = 0.5;
     elseif t > first_det_frame_fro
        prior1 = marginalsWTA(1,t-1);
     end
     
     if t < first_det_frame_cor 
        % Before any measurment nullify the weigth for this sensor
        prior2 = 0;     
     elseif t == first_det_frame_cor
        % First observation we have no prior, so use 0.5 for each sensor
        prior2 = 0.5;
     else
        prior2 = marginalsWTA(2,t-1);
     end
    
    if ~usePriors
        prior1 = 1;
        prior2 = 1;
    end
    
    % Calculate the posterior likelihood for each filter. 
    posterior1 = prior1*prob1;
    posterior2 = prior2*prob2;
    
    % These are our priors for t+1. We'll normalise them to prevent
    % underflow
    marginalsWTA(1,t) = posterior1/(posterior1+posterior2);
    marginalsWTA(2,t) = posterior2/(posterior1+posterior2);
    
    if posterior1 > posterior2
        winnerTakesAll(:,t) = pred1(1:2);        
    else
        winnerTakesAll(:,t) = pred2(1:2);
    end
    
    % ---------------------------------------------------------------------
    %% Option 2: Use the 'Weighted Sum' strategy.
    % ---------------------------------------------------------------------
    % weight each posterior and then normalise the result to give us
    % a final weighting.
    
%      if t < first_det_frame_fro 
%         % Before any measurment nullify the weigth for this sensor
%         prior1 = 0;
     if t == first_det_frame_fro
        % First observation we have no prior, so use 0.5 for each sensor
        prior1 = 0.5;
     elseif t > first_det_frame_fro
        prior1 = marginalsWS(1,t-1);
     end
     
%      if t < first_det_frame_cor 
%         % Before any measurment nullify the weigth for this sensor
%         prior2 = 0;     

    if t == first_det_frame_cor
        % First observation we have no prior, so use 0.5 for each sensor
        prior2 = 0.5;
     else
        prior2 = marginalsWS(2,t-1);
     end
    
    if ~usePriors
        prior1 = 1;
        prior2 = 1;
    end
    
%     prob1 = 1/( abs(prob1) + eps);
%     prob2 = 1/( abs(prob2) + eps);

    % Calculate our marginals
    px1 = prior1*prob1 * sensor1Weight;
    px2 = prior2*prob2 * sensor2Weight;
    
    if (px1+px2) > 0
        px1Norm = px1/(px1+px2);
        px2Norm = px2/(px1+px2);
    else
        px1Norm = marginalsWS(1,t-1);
        px2Norm = marginalsWS(2,t-1);
    end
    
    % Store them for t+1
    marginalsWS(1,t) = px1Norm;
    marginalsWS(2,t) = px2Norm;
    
    % Calculate the final 'prediction' based on our weights
    weightedSum(:,t) = (px1Norm*pred1(1:2))+(px2Norm*pred2(1:2));  
    
    %figure(42); plot_kalman_filter( fused.gt, fused.obs, fused.predictions, gp_img ); title('Fused Observations')
    %figure(44), hold on, plot(weightedSum(1,t),weightedSum(2,t),'r.')
end

% Plot the results
[ mse_fro, ~ ] = calculate_mse( sensor1.predictions, {sensor1.gt} );
[ mse_cor, ~ ] = calculate_mse( sensor2.predictions, {sensor2.gt} );

[ mse_fus_obs, ~ ] = calculate_mse( fused.predictions, fused.gt );
[ mse_fus_wta, ~ ] = calculate_mse( winnerTakesAll, fused.gt );
[ mse_fus_wsu, ~ ] = calculate_mse( weightedSum, fused.gt );


figure(40); plot_kalman_filter( {sensor1.gt}, {sensor1.obs}, sensor1.predictions, gp_img );
figure(41); plot_kalman_filter( {sensor2.gt}, {sensor2.obs}, sensor2.predictions, gp_img );

figure(42); plot_kalman_filter( fused.gt, fused.obs, fused.predictions, gp_img ); title('Fused Observations')
figure(43); plot_kalman_filter( fused.gt, fused.obs, winnerTakesAll, gp_img ); title('Winner Takes All')
figure(44); plot_kalman_filter( fused.gt, fused.obs, weightedSum, gp_img ); title('Weighted Sum')

disp(sprintf('%.4f & %.4f & %.4f & %.4f & %.4f\\\\', mse_fro, mse_cor, mse_fus_obs, mse_fus_wta, mse_fus_wsu));

% Report purposes
%addpath('../PlotUtils');
%figure(1); printimage('../../../Report/figs/KF_fus_s1');