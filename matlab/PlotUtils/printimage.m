function printimage(foutname)
%PRINTIMAGE Saves the figure in a file and then crops the white part (this
%function is used for report purposes only)
    print('-dpng', foutname); crop(strcat(foutname,'.png'));
end