function [ nt_gp, gt_gp, nt ] = save_gp_projection( nt, gt, T, sname )
%SAVE_GP_PROJ Summary of this function goes here
%
%   nt_path: path of the .txt file that contains the naive tracker output
%   gt: ground truth .mat for corridor or front
%   T: TFORM struct contaning the homography

    nt_gp = tformfwd(T,nt(:,7),nt(:,8));
    
    gt_gp = gt;
    [gt_gp(:,:,1), gt_gp(:,:,2)] = tformfwd(T,gt(:,:,1),gt(:,:,2));
    
    nt_save = [nt(:,1:6),  nt_gp];
    csvwrite(sname,nt_save);
end

