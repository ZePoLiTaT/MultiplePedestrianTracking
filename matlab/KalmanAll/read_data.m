function [ nt_frames, nt_ppl, naive_tracker ] = read_data( path )
%READ_DATA Summary of this function goes here
%   Detailed explanation goes here

    % Read the naive tracker data
    naive_tracker = csvread(path);
    nt_frames = naive_tracker(end,1) + 1;
    nt_ppl = max(naive_tracker(:,2)) + 1;
    naive_tracker(:,7) = naive_tracker(:,3) + naive_tracker(:,5)/2;
    naive_tracker(:,8) = naive_tracker(:,4) + naive_tracker(:,6)/2;

end

