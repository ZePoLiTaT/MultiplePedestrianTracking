function [ mse_dnt, mse_filt ] = calculate_mse_old( nt_pos, x, xfilt )
%CALCULATE_MSE Summary of this function goes here
%   Detailed explanation goes here

    ix_gt_zeros = all(x~=0);
    ix_nt_zeros = all(nt_pos~=(-1));

    dnt = x([1 2],:) - nt_pos([1 2],:);
    dnt = dnt( :, ix_gt_zeros & ix_nt_zeros );
    mse_dnt = sqrt(sum(sum(dnt.^2)));

    dfilt = x([1 2],:) - xfilt([1 2],:);
    dfilt = dfilt( :, ix_gt_zeros  );
    mse_filt = sqrt(sum(sum(dfilt.^2)));
end

