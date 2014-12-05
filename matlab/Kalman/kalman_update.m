function [ xnew, Pnew, prob] = kalman_update( y, H, xpred, Q, R, F, P)
%kalman_update Perofrms the update step of the Kalman filter
% Inputs:
%   y     : Observation
%   H     : Observation model
%   xpred : State estimate (prediction)
%   Q     : Estimated process noise covariance
%   R     : Measurement (observation) covariance
%   F     : Transition model
%   P     : Posterior error covariance
%
% Outputs: 
%   xnew : Corrected estimate of state  
%   Pnew : Updated posterior error covariance matrix
%   prob : Probability of innovation given the posterior error covariance
% predict next covariance
    P = F*P*F' + Q;

    e = y - H*xpred; % error (innovation)
    n = length(e);
    ss = length(F);
    S = H*P*H' + R;
    Sinv = inv(S);
    ss = length(Q);
    
    % If there is no observation vector, set K = zeros(ss).
    if( all( y<0 ) )
        K = zeros(ss,n);
    else
        K = P*H'*Sinv; % Kalman gain matrix
    end
    
    xnew = xpred + K*e;
    Pnew = (eye(ss) - K*H)*P;
    
    prob = gaussian_prob(e, zeros(1,length(e)), S, 0);

end

