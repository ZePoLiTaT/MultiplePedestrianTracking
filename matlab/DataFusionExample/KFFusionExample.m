%% Example (2) of data fusion using scores.
%
% Data Fusion and Tracking
% R. H. Baxter, November 2014
%
% This script demonstrates how sensor fusion could be performed on a single
% dimension signal (e.g. temperature). There are other (and probably better)
% ways of doing the fusion, this script serves only as an example of some
% of the possibilities.
%
% Scenario: Two sensors are providing observations (measurements), and two
% filters are running estimating the location of the same target. Each
% sensor is biased - this is reflected via it's mean 
% 
% If the sensors are identical in terms of sigma (and each sensor is
% weighted equally), then the 'ideal' target position should be 0.
%
% If one sensor is less reliable than the other (e.g. sensor1.sigma >
% sensor2.sigma) then we would expect the mean target position to shift
% towards the mean of sensor2 (because it is more reliable).

close all;
      
%% Tunable parameters
sensor1Weight = 0.5;
sensor2Weight = 1-sensor1Weight;

sensor1.sigma = 1;
sensor2.sigma = 1;

sensor1.mean = -1;
sensor2.mean = 1;

numObs = 100;

usePriors = 0;

%% Initialise the observations by drawing random observations from each
% sensor. 
sensor1.obs = normrnd(sensor1.mean, sensor1.sigma, numObs, 1);
sensor2.obs = normrnd(sensor2.mean, sensor2.sigma, numObs, 1);

%% Initialise other variables up front for efficiency
sensor1.predictions = zeros(1,numObs);
sensor2.predictions = zeros(1,numObs);
marginalsWTA = zeros(2,numObs);
marginalsWS = zeros(2,numObs);
marginalsSP = zeros(2,numObs);
winnerTakesAll = zeros(1,numObs);
weightedSum = zeros(1,numObs);
product = zeros(1,numObs);

%% Initialise some Kalman Filtering parameters
pred1 = [sensor1.mean; 0]; % prior for tracker 1
pred2 = [sensor2.mean; 0]; % prior for tracker 2
F = [1 1; 0 1]; % Transition model
P1 = eye(2)*0.1; % Posterior error covariance for tracker 1
P2 = eye(2)*0.1; % Posterior error covariance for tracker 2
Q = eye(2)*0.1; % Process noise covariance (single target so the same for both trackers)
H = [1 0]; % Observation model
R = 0.1; % Measurement (observation) covariance

for t = 1:numObs
    if t == 1
        % First observation we have no prior, so use 0.5 for each sensor
        prior1 = 0.5;
        prior2 = 0.5;
    else
        prior1 = marginalsWTA(1,t-1);
        prior2 = marginalsWTA(2,t-1);
    end
    
    
   if ~usePriors
       prior1 = 1;
       prior2 = 1;
   end
    
    % assume each filter predicts some value (we'll use the mean for
    % simplicity)
    pred1 = kalman_predict(F, pred1);
    pred2 = kalman_predict(F, pred2);
    
    sensor1.predictions(t) = pred1(1);
    sensor2.predictions(t) = pred2(1);
    
    [ pred1, P1, prob1] = kalman_update(sensor1.obs(t), H, pred1, Q, R, F, P1); 
    [ pred2, P2, prob2] = kalman_update(sensor2.obs(t), H, pred2, Q, R, F, P2);
       
    % Calculate the posterior likelihood for each filter. 
    posterior1 = prior1*prob1;
    posterior2 = prior2*prob2;
    
    % These are our priors for t+1. We'll normalise them to prevent
    % underflow
    marginalsWTA(1,t) = posterior1/(posterior1+posterior2);
    marginalsWTA(2,t) = posterior2/(posterior1+posterior2);
    
    %% Option 1: Use the 'Winner Takes All' strategy for choosing our resulting
    % prediction. 
    if posterior1 > posterior2
        winnerTakesAll(t) = pred1(1);        
    else
        winnerTakesAll(t) = pred2(1);
    end
       
    
    %% Option 2: Use the 'Weighted Sum' strategy.
    %
    % weight each posterior and then normalise the result to give us
    % a final weighting.
    
    if t == 1
        % First observation we have no prior, so use 0.5 for each sensor
        prior1 = 0.5;
        prior2 = 0.5;
    else
        prior1 = marginalsWS(1,t-1);
        prior2 = marginalsWS(2,t-1);
    end
    
   if ~usePriors
       prior1 = 1;
       prior2 = 1;
   end
    
    % Calculate our marginals
    px1 = sensor1Weight*prior1*prob1;
    px2 = sensor2Weight*prior2*prob2;
    px1Norm = px1/(px1+px2);
    px2Norm = px2/(px1+px2);
    
    % Store them for t+1
    marginalsWS(1,t) = px1Norm;
    marginalsWS(2,t) = px2Norm;
    
    % Calculate the final 'prediction' based on our weights
    weightedSum(t) = (px1Norm*pred1(1))+(px2Norm*pred2(1));       
end

% Plot some results
plot(1:numObs, winnerTakesAll, 'r');
hold on;
plot(1:numObs, weightedSum, 'k');

plot(1:numObs, sensor1.predictions, '--b');
plot(1:numObs, sensor2.predictions, '--g');

plot(1:numObs, sensor2.obs, 'gsq')
plot(1:numObs, sensor1.obs, 'bsq');

legend('WinnerTakesAll', 'WeightedSum', 'Sensor 1', 'Sensor 2', 'Location', 'EastOutside');

% Output some mean's for each strategy.
fprintf('Mean position from Winner Takes all: %.2f\n', mean(winnerTakesAll));
fprintf('Mean position from Weighted sum: %.2f\n', mean(weightedSum));
