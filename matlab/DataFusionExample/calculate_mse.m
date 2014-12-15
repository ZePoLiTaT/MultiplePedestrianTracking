function [ mse, gt_min ] = calculate_mse( naive_track_list, grount_truth_list) %, xfilt )
%CALCULATE_MSE Summary of this function goes here
%   Detailed explanation goes here

%     ix_gt_zeros = all(grount_truth_list~=0);
%     ix_nt_zeros = all(naive_track_list~=(-1));
% 
%     dnt = grount_truth_list([1 2],:) - naive_track_list([1 2],:);
%     dnt = dnt( :, ix_gt_zeros & ix_nt_zeros );
%     mse_dnt = sqrt(sum(sum(dnt.^2)));

    gt_min = zeros(size(naive_track_list));
    num_gt = numel( grount_truth_list );
    
    mse_frame = zeros( num_gt, 1 );
    mse_sum = 0;
    mse_N = 0;
    
    for t=1:size( naive_track_list,2 )
        
        naive_track = naive_track_list(:,t);
        if all( naive_track<=0 )
            if num_gt>1 & ~all( grount_truth_list{2}(:,t) <=0 )
                gt_min(:,t) = grount_truth_list{2}(:,t);
            else
                gt_min(:,t) = grount_truth_list{1}(:,t);
            end
            continue;
        end
        
        for gi = 1:num_gt
            
            groun_truth = grount_truth_list{gi}(:,t);
            if all( groun_truth<=0 )
                continue;
            end
            
            err = naive_track - groun_truth;
            mse_frame(gi) = sqrt( sum(err.*err) );
        end
        
        [minerr, ix] = min( mse_frame );
        gt_min(:,t) = grount_truth_list{ix}(:,t);
        
        mse_sum = mse_sum + minerr;
        mse_N = mse_N + 1;
        
    end

    mse = mse_sum / mse_N;
end

