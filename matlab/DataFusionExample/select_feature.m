function [ observation ] = select_feature( pred, observation_list )
%SELECT_FEATURE Summary of this function goes here
%   Detailed explanation goes here

    diff = bsxfun(@minus, observation_list, pred);
    dist = sqrt( sum(diff.*diff) );
    
    [mindist, minind] = min( dist );
    observation = observation_list(:, minind);
end

