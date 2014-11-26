% script to extract the two simultaneous data frames
% just change the input files from the CAVIAR datasets
% http://homepages.inf.ed.ac.uk/rbf/CAVIARDATA1/

clear all, clc

% Read the naive tracker data
naive_tracker = csvread('../../data/shop2_zntmod_cor_out.txt');
nt_frames = naive_tracker(end,1) + 1;
nt_ppl = max(naive_tracker(:,2)) + 1;
naive_tracker(:,7) = naive_tracker(:,3) + naive_tracker(:,5)/2;
naive_tracker(:,8) = naive_tracker(:,4) + naive_tracker(:,6)/2;

cmap = hsv(nt_ppl);
figure(90), imshow(imread('../../data/OneLeaveShop2cor0000.jpg'));
for i=0:nt_ppl-1
    track_ix = find(naive_tracker(:,2)==i);
    hold on, plot(naive_tracker(track_ix,7),naive_tracker(track_ix,8),'.','Color',cmap(i+1,:));
    hold on, text(100+20*i,245,num2str(i), 'Color',cmap(i+1,:));
    %pause
end
pause

% % NB the tracks in this example are out by 73frames i.e. cor00073 corresponds to front000000
% % see the timestamp on the frame to manually align other sequences
% 
% % read in the corridor view
% load tracks_cor_fro.mat;
% 
% % read the xml file
% file = 'cols2gt.xml';
% 
% % parse the xml into a matlab "struct"
% t = xml2struct(file);
% 
% % extract the track data from the struct
% tracks_cor = get_tracks_from_xml(t);

load('../../data/cols2gt_cor.mat');

figure(80), imshow(imread('../../data/OneLeaveShop2cor0000.jpg'));
cmap = hsv(nt_ppl);
for i=1:length(tracks_cor(1,:,1))
    track_ix = find(naive_tracker(:,2)==i);
    hold on, plot(tracks_cor(:,i,1),tracks_cor(:,i,2),'.','Color',cmap(i+1,:));
    hold on, text(100+20*i,245,num2str(i), 'Color',cmap(i+1,:));
    %pause
end

% hold on, plot(tracks_cor(:,:,1),tracks_cor(:,:,2),'.');
% for i=1:length(tracks_cor(1,:,1))
%     hold on, text(tracks_cor(1,i,1),tracks_cor(1,i,2),num2str(i));
%     %pause
% end


% % do all of the above for the front view
% file = 'fols1gt.xml';
% t = xml2struct(file);
% tracks_fro = get_tracks_from_xml(t);
% figure(2)
% imshow(imread('../../data/OneLeaveShop1front0000.jpg'))
% hold on, plot(tracks_fro(:,:,1),tracks_fro(:,:,2),'.');
% 
% for i=1:length(tracks_fro(1,:,1))
%     figure(2), hold on, text(tracks_fro(1,i,1),tracks_fro(1,i,2),num2str(i));
%     
% end





