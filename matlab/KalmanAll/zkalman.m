clc; clear; %close all;

addpath(genpath('.'))
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

% initx = [10 10 1 0]';
% initV = 10*eye(ss);
% seed = 9;
% rand('state', seed);
% randn('state', seed);
% T = 15;
% [x,y] = sample_lds(F, H, Q, R, initx, T);

gt_id = 5; nt_id = 11;
[x, y, first_det_frame, last_det_frame] = load_naive_tracks('../../data/shop2_zntmod_cor_out.txt', '../../data/cols2gt_cor.mat', nt_id, gt_id );
%person_id = 1;
%[x, y, first_det_frame] = load_naive_tracks('cols2ztrack_cor.txt', 'cols2gt_cor.mat', person_id );

% % Remove observations before the first detection
% y = y( :, first_det_frame:end );
% x = x( :, first_det_frame:end );

% Remove observations before the first detection
% and remove observations THRS_F frames after the last detection
THRS_F = 30;
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

dfilt = x([1 2],:) - xfilt([1 2],:);
mse_filt = sqrt(sum(sum(dfilt.^2)))

dsmooth = x([1 2],:) - xsmooth([1 2],:);
mse_smooth = sqrt(sum(sum(dsmooth.^2)))


figure(1)
clf
set(gca,'ydir','reverse')
%subplot(2,1,1)
hold on
plot(x(1,:), x(2,:), 'ks-');
plot(y(1,:), y(2,:), 'g*');

%plot(xfilt(1,1:400), xfilt(2,1:400), 'rx:');
plot(xfilt(1,:), xfilt(2,:), 'rx:');
% for t=1:T
%     plotgauss2d(xfilt(1:2,t), Vfilt(1:2, 1:2, t)); 
% end
hold off
legend('true', 'observed', 'filtered', 3)
xlabel('x')
ylabel('y')



% 3x3 inches
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.eps');
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_filtered.jpg');


figure(2)
clf
set(gca,'ydir','reverse')
%subplot(2,1,2)
hold on
plot(x(1,:), x(2,:), 'ks-');
plot(y(1,:), y(2,:), 'g*');
plot(xsmooth(1,:), xsmooth(2,:), 'rx:');
% for t=1:T
%     plotgauss2d(xsmooth(1:2,t), Vsmooth(1:2, 1:2, t)); 
% end
hold off
legend('true', 'observed', 'smoothed', 3)
xlabel('x')
ylabel('y')


% 3x3 inches
set(gcf,'units','inches');
set(gcf,'PaperPosition',[0 0 3 3])  
%print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.jpg');
%print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.eps');
