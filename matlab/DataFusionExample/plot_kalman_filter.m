function [ ] = plot_kalman_filter( gt_pos, nt_pos, xsmooth, gp_img )
%PLOT_KALMAN_FILTER Summary of this function goes here
%   Detailed explanation goes here

    figure
    imshow(gp_img)
    hold on;
    %set(gca,'ydir','reverse')
    %subplot(2,1,2)
    hold on
    plot(gt_pos(1,:), gt_pos(2,:), 'gs-');
    plot(nt_pos(1,:), nt_pos(2,:), 'b*');
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

end

