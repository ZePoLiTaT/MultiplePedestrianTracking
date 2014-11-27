function [ nt_gp, gt_gp, nt ] = save_gp_proj( nt_path, gt, T )
%SAVE_GP_PROJ Summary of this function goes here
%
%   nt_path: path of the .txt file that contains the naive tracker output
%   gt: ground truth .mat for corridor or front
%   T: TFORM struct contaning the homography

    % extract the naive tracker data in matlab format
    [ nt_frames, nt_ppl, nt ] = read_data( nt_path );
    
    nt_gp = tformfwd(T,nt(:,7),nt(:,8));
    
    gt_gp = gt;
    [gt_gp(:,:,1) gt_gp(:,:,2)] = tformfwd(T,gt(:,:,1),gt(:,:,2));

end

