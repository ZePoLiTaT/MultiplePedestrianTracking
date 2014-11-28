function [xpred] = kalman_predict(F, state)
% KALMAN_UPDATE Do a one step update of the Kalman filter
% [xpred] = kalman_update(F, state)
%
% INPUTS:
% F - Transition model
% x(:) - E[X | y(:, 1:t-1)] prior mean (state)
%
% OUTPUTS (where X is the hidden state being estimated)
%  xpred - New estimated state

xpred = F*state;
