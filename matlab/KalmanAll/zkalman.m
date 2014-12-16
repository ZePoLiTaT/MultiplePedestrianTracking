clc; clear; %close all;
addpath(genpath('.'))

%--------------------------------------------------------------------------
%   TEST SELECTION
%--------------------------------------------------------------------------
vid_id = 1;

seq = 'cor';
%seq = 'front';

%folder = '/gplane';
folder = '';

% Id's correspondences
%gt_id = 6; nt_id = 2;     % cor1: Person 1
%gt_id = 2; nt_id = 2;      % fro1: Person 1

%gt_id = 1; nt_id = 2;      % cor2: Person 1
%gt_id = 5; nt_id = 11;     % cor2: Person 2

%img_file = sprintf('../../data%s/OneLeaveShop%d%s0000.jpg',folder,vid_id,seq);
%img_file = 'OneLeaveShop1front0178.jpg';
img_file = 'OneLeaveShop1cor0100.jpg';

% ----> 1. Naive tracker detections
nt_cor_file = sprintf('../../data%s/OneLeaveShop%d%s_NTracks.txt',folder,vid_id,seq);

% ----> 2. Ground truth
gt_cor_file = sprintf('../../data%s/tracks%d_cor_fro.mat',folder,vid_id);
load(gt_cor_file);

if strcmp(seq, 'cor')
    tracks = tracks_cor;
    if vid_id == 1
        gt_id = 6; nt_id = 2;       % cor1: Person 1
    else
        gt_id = 1; nt_id = 2;       % cor2: Person 1
        %gt_id = 5; nt_id = 11;     % cor2: Person 2
    end
else
    tracks = tracks_fro;
    
    if vid_id == 1
        gt_id = 2; nt_id = 2;      % fro1: Person 1
    end    
end


% Make a point move in the 2D plane
% State = (x y xdot ydot). We only observe (x y).

% This code was used to generate Figure 15.9 of "Artificial Intelligence: a Modern Approach",
% Russell and Norvig, 2nd edition, Prentice Hall, 2003.

% X(t+1) = F X(t) + noise(Q)
% Y(t) = H X(t) + noise(R)

ss = 4; % state size
os = 2; % observation size

F = [1 0 1 0; 
     0 1 0 1; 
     0 0 1 0; 
     0 0 0 1]; 
 
H = [1 0 0 0; 
     0 1 0 0];
 
Q = 0.1*eye(ss);
R = 1*eye(os);


[x, y, first_det_frame, last_det_frame] = ...
    load_naive_tracks(nt_cor_file, tracks, nt_id, gt_id );

% [x, y, first_det_frame, last_det_frame] = load_naive_tracks( ...
%     '../../data/shop2_zntmod_cor_out.txt', ...
%     '../../data/cols2gt_cor.mat', nt_id, gt_id );

% Remove observations before the first detection
% and remove observations THRS_F frames after the last detection
THRS_F = 0;
y = y( :, first_det_frame:last_det_frame+THRS_F );
x = x( :, first_det_frame:last_det_frame+THRS_F );


% Take the initial position as the initial detection
initx = [y(:,1); 0; 0];
% Initial velocity is 0
initV = 0*eye(ss);
% Get the number of frames
T = size(x,2);


[xfilt, Vfilt, VVfilt, loglik] = kalman_filter(y, F, H, Q, R, initx, initV);
[xsmooth, Vsmooth] = kalman_smoother(y, F, H, Q, R, initx, initV);

ix_gt_zeros = all(x~=0);
ix_nt_zeros = all(y~=(-1));

dnt = x([1 2],:) - y([1 2],:);
dnt = dnt( :, ix_gt_zeros & ix_nt_zeros );
mse_dnt = sqrt(sum(sum(dnt.^2))) / size(dnt,2)

dfilt = x([1 2],:) - xfilt([1 2],:);
dfilt = dfilt( :, ix_gt_zeros   );
mse_filt = sqrt(sum(sum(dfilt.^2))) / size(dfilt,2)

dsmooth = x([1 2],:) - xsmooth([1 2],:);
dsmooth = dsmooth(:, ix_gt_zeros   );
mse_smooth = sqrt(sum(sum(dsmooth.^2))) / size(dsmooth,2)


figure(1)
imshow(img_file);
%set(gca,'ydir','reverse')
%subplot(2,1,1)
hold on
plot(x(1,:), x(2,:), 'gs-');
plot(y(1,ix_nt_zeros), y(2,ix_nt_zeros), 'b*');

%plot(xfilt(1,1:400), xfilt(2,1:400), 'rx:');
plot(xfilt(1,:), xfilt(2,:), 'rx:');
% for t=1:T
%     plotgauss2d(xfilt(1:2,t), Vfilt(1:2, 1:2, t)); 
% end
hold off
legend('true', 'observed', 'filtered', 3)
% xlabel('x')
% ylabel('y')

% 3x3 inches
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.eps');
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.jpg');

% figure(2)
% imshow('OneLeaveShop1cor0100.jpg');
% %set(gca,'ydir','reverse')
% %subplot(2,1,2)
hold on
% plot(x(1,ix_gt_zeros), x(2,ix_gt_zeros), 'ks-');
% plot(y(1,ix_nt_zeros), y(2,ix_nt_zeros), 'g*');
plot(xsmooth(1,:), xsmooth(2,:), 'wx:');
% % for t=1:T
% %     plotgauss2d(xsmooth(1:2,t), Vsmooth(1:2, 1:2, t)); 
% % end
% hold off
% legend('true', 'observed', 'smoothed', 3)
% xlabel('x')
% ylabel('y')

% 3x3 inches
% set(gcf,'units','inches');
% set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.jpg');
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.eps');
