function [ tp, fp,fn ] = stats_metrics( gt, nt )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

    N_FRAMES = size(nt,2);
    
    tp = 0;
    fp = 0;
    fn = 0;
        
    for i=1:N_FRAMES
       
        % x,y from naive trakcs
        xnt = nt(1,i);
        ynt = nt(2,i);
        
        xgt = gt(1,i);
        ygt = gt(2,i);
        
        % tp
        if( (xnt~=-1) && (ynt~=-1) ) && ( (xnt~=0) && (ynt~=0) )
            tp = tp + 1;            
        % fp    
        elseif( (xnt~=-1) && (ynt~=-1) ) && ( (xnt==0) && (ynt==0) )
            fp = fp + 1;
        % fn        
        elseif( (xnt==-1) && (ynt==-1) ) && ( (xnt~=0) && (ynt~=0) )
            fn = fn + 1;
        end
    end

end

