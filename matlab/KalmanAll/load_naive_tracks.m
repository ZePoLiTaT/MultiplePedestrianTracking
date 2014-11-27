function [gt_pos, nt_pos, first_det_frame, last_det_frame] = load_naive_tracks( path_zt, tracks_cor, nt_id, gt_id )
%LOAD_NAIVE_TRACKS Summary of this function goes here
%   Detailed explanation goes here

    % Read the naive tracker data file
    [ nt_frames, nt_ppl, naive_tracker ] = read_data(path_zt);
    
    % The 2nd column of naive_tracker has the ids of the tracks
    track_ix = find( naive_tracker(:,2) == nt_id );
    person_tracks = naive_tracker( track_ix(:), :);

    % Fill the detections of the ztracker into the observation matrix
    nt_pos = ones(2,nt_frames) * (-1);
    frames = person_tracks(:,1);
    
    % x are the rows in matlab
    nt_pos(:,frames) = person_tracks(:, [7,8])';

    % Find the first detection frame and take it as starting point
    first_det_frame = person_tracks(1,1);
    last_det_frame = person_tracks(end,1);
    
    % Remove frames that are before the 1st observation of the person
    %nt_pos = nt_pos(first_det_frame:end,:)';
   
    [X,Y,Z] = size(tracks_cor);
    gt_pos = reshape( tracks_cor(:, gt_id, :), X, Z)';
    
    
end

    