clear all, clc

vid_id = 2;

% NT file names
nt_cor_file = sprintf('../../data/shop%d_zntmod_cor_out.txt',vid_id);

% GT file names
gt_corimg_file = sprintf('../../data/OneLeaveShop%dcor0000.jpg',vid_id);
gt_cor_file = sprintf('../../data/tracks%d_cor_fro.mat',vid_id);


% Read the naive tracker data
naive_tracker = csvread(nt_cor_file);
nt_frames = naive_tracker(end,1) + 1;
nt_ppl = max(naive_tracker(:,2)) + 1;
naive_tracker(:,7) = naive_tracker(:,3) + naive_tracker(:,5)/2;
naive_tracker(:,8) = naive_tracker(:,4) + naive_tracker(:,6)/2;

cmap = hsv(nt_ppl);
figure(90), imshow(imread(gt_corimg_file));
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

pause

% % NB the tracks in this example are out by 73frames i.e. cor00073 corresponds to front000000
% % see the timestamp on the frame to manually align other sequences
load(gt_cor_file);
% 
figure(80);imshow(imread(gt_corimg_file));
hold on, plot(tracks_cor(:,:,1),tracks_cor(:,:,2),'.');

lbl = [1:length(tracks_cor(1,:,1))]';
lbl = cellstr(num2str(lbl))';
lbl = strtrim(lbl);
legend( lbl )

% for i=1:length(tracks_cor(1,:,1))
%     lbl{i} = num2str(i);
%     %hold on, text(tracks_cor(1,i,1),tracks_cor(1,i,2),num2str(i));
%     %pause
% end
% legend(lbl)