function [ ] = plot_kalman_filter( gt_pos, nt_pos, kf_pos, gp_img )
%PLOT_KALMAN_FILTER Summary of this function goes here
%   Detailed explanation goes here

    [ROWS,COLS] = size(gp_img);

    %plot only valid data
    ix_valid_gt = all(gt_pos > 0) & (gt_pos(1,:) < COLS) & (gt_pos(2,:) < ROWS);
    ix_valid_nt = all(nt_pos > 0) & (nt_pos(1,:) < COLS) & (nt_pos(2,:) < ROWS);
    ix_valid_kf = all(kf_pos > 0) & (kf_pos(1,:) < COLS) & (kf_pos(2,:) < ROWS);

    imshow(gp_img)
    hold on;
    %set(gca,'ydir','reverse')
    %subplot(2,1,2)
    hold on
    plot(gt_pos(1,ix_valid_gt), gt_pos(2,ix_valid_gt), 'ys-');
    plot(nt_pos(1,ix_valid_nt), nt_pos(2,ix_valid_nt), 'g*');
    plot(kf_pos(1,ix_valid_kf), kf_pos(2,ix_valid_kf), 'rx:');
    % for t=1:T
    %     plotgauss2d(xsmooth(1:2,t), Vsmooth(1:2, 1:2, t)); 
    % end
    hold off
    legend('true', 'observed', 'smoothed', 3)
%     xlabel('x')
%     ylabel('y')


    % 3x3 inches
    set(gcf,'units','inches');
    set(gcf,'PaperPosition',[0 0 3 3])  
    %print(gcf,'-djpeg','-r100', '/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.jpg');
    %print(gcf,'-depsc','/home/eecs/murphyk/public_html/Bayes/Figures/aima_smoothed.eps');

end

