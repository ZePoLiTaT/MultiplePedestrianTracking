function [ ] = plot_kalman_filter( gt, obs, pred, gp_img )
%PLOT_KALMAN_FILTER Summary of this function goes here
%   Detailed explanation goes here

    [ROWS,COLS] = size(gp_img);
    imshow(gp_img), hold on
    
    cmap = jet(5); %rand(2+num_gt, 3);

    for i=1:numel(gt)
        %plot only valid data
        ix_valid_gt = all(gt{i} > 0) & (gt{i}(1,:) < COLS) & (gt{i}(2,:) < ROWS);
        
        plot(gt{i}(1,ix_valid_gt), gt{i}(2,ix_valid_gt),'s-','Color',cmap(i,:)); 
    end
    
    for i=1:numel(obs)
        %plot only valid data
        ix_valid_nt = all(obs{i} > 0) & (obs{i}(1,:) < COLS) & (obs{i}(2,:) < ROWS);
        
        plot(obs{i}(1,ix_valid_nt), obs{i}(2,ix_valid_nt),'*','Color',cmap(2+i,:));%, 'g*');
    end
    
    ix_valid_kf = all(pred > 0) & (pred(1,:) < COLS) & (pred(2,:) < ROWS);
    plot(pred(1,ix_valid_kf), pred(2,ix_valid_kf),'x:','Color',cmap(5,:));%, 'rx:');
    hold off
        %legend('true', 'observed', 'smoothed', 3)
    %     xlabel('x')
    %     ylabel('y')


    % 3x3 inches
    set(gcf,'units','inches');
    set(gcf,'PaperPosition',[0 0 3 3])  
    
end

