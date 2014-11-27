function [ nt_frames, nt_ppl, naive_tracker ] = read_data( path )
%READ_DATA Summary of this function goes here
%   Detailed explanation goes here

    % Read the naive tracker data
    naive_tracker = csvread(path);
    nt_frames = naive_tracker(end,1) + 1;
    nt_ppl = max(naive_tracker(:,2)) + 1;

end

