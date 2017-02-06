function my_draw_detection_res(im, bbox_candidate,filename,res_path)
%select the bbox with the largest probablity to draw
%170121
if(isempty(bbox_candidate))
    disp('warning in my_draw_detection,empty candidate');
    f=figure;
    
    imshow(im/255);
    set(gcf,'outerposition',get(0,'screensize'));
    axis image;
    axis off;
    set(gcf, 'Color', 'white');
    %from figure axes to image
    F=getframe(gca);
    Image=frame2im(F);imwrite(Image,[res_path filename '.jpg']);
    close(f);
    
    return;
end

f=figure;

imshow(im/255);
set(gcf,'outerposition',get(0,'screensize'));
axis image;
axis off;
set(gcf, 'Color', 'white');
%line style
c = 'r';
t = 2;
s = '-';

[val,ind]=max(bbox_candidate(:,end));
%calbbox=bbox_candidate(ind,1:4);
calbbox=bbox_candidate(ind,1:5); %first four elements are bbox, last one is prob


x1 = calbbox(:, 1);
y1 = calbbox(:, 2);
x2 = calbbox(:, 3);
y2 = calbbox(:, 4);
l=line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', ...
    'color', c, 'linewidth', t, 'linestyle', s);
% text(double(x1), double(y1) - 2, ...
%     sprintf('%.4f', calbbox(1, end)), ...
%     'backgroundcolor', 'b', 'color', 'w', 'FontSize', 10);
text(double(x1), double(y1) +2, ...
    sprintf('%.4f', calbbox(1, end)), ...
    'backgroundcolor', 'b', 'color', 'w', 'FontSize', 10);

%from figure axes to image
F=getframe(gca);
Image=frame2im(F);imwrite(Image,[res_path filename '.jpg']);
close(f);
%to form [col row w h]
% calbbox_trans=[calbbox(1:2) calbbox(3)-calbbox(1) calbbox(4)-calbbox(2)];
% gtbox_trans=[gtbox(1:2) gtbox(3)-gtbox(1) gtbox(4)-gtbox(2)];
%
% overlapRatio = bboxOverlapRatio(calbbox_trans, gtbox_trans, 'Union');
%
% if(overlapRatio>=insecthresh)
%     bin_res=1;
% else
%     bin_res=0;
%
% end


end

