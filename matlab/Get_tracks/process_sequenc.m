function [ ] = process_sequenc( nt_cor_file, gt_tracks, gt_corimg_file )
%PROCESS_SEQUENC Summary of this function goes here
%   Detailed explanation goes here

    %-----------------------------------------------------------------
    % NAIVE TRACKER
    %-----------------------------------------------------------------
    % Read the naive tracker data
    naive_tracker = csvread(nt_cor_file);
    nt_frames = naive_tracker(end,1) + 1;
    nt_ppl = max(naive_tracker(:,2)) + 1;
    naive_tracker(:,7) = naive_tracker(:,3) + naive_tracker(:,5)/2;
    naive_tracker(:,8) = naive_tracker(:,4) + naive_tracker(:,6)/2;

    cmap = rand(nt_ppl, 3); %jet(nt_ppl);
    figure, imshow(imread(gt_corimg_file));
    for i=0:nt_ppl-1
        track_ix = find(naive_tracker(:,2)==i);
        hold on, plot(naive_tracker(track_ix,7),naive_tracker(track_ix,8),'.','Color',cmap(i+1,:));
        %hold on, text(100+20*i,245,num2str(i), 'Color',cmap(i+1,:));
        %pause
    end

    lbl = ( [1:nt_ppl] - 1 )';  %zero based index from c++
    lbl = cellstr(num2str(lbl))';
    lbl = strtrim(lbl);
    legend( lbl )

    %-----------------------------------------------------------------
    % GROUND TRUTH
    %-----------------------------------------------------------------
    

    % Corridor image
    figure;imshow(imread(gt_corimg_file));
    hold on, plot(gt_tracks(:,:,1),gt_tracks(:,:,2),'.');

    lbl = [1:length(gt_tracks(1,:,1))]';
    lbl = cellstr(num2str(lbl))';
    lbl = strtrim(lbl);
    legend( lbl )
end

