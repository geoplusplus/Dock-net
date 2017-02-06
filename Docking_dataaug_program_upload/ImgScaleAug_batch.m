function [ Scalemean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImgScaleAug_batch( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,scalefactor,boxesall)
%scale data augmentation

disp('scale aug start...');   

%parpool('local',6);
%imgdata_aug=[];

trainidx=find(set==1);
%imgdata_aug=[];
num_beforeaug=numel(namelistcell);

meanR=0;
meanG=0;
meanB=0;
cur_imgnum=0;

probname=['VTS_01_1_1.mp420161026T1447539174_scale1.25_leftdown.jpg', ...
    'VTS_01_1_1.mp420161026T1447025949_scale1.25_leftdown.jpg', ...
    'VTS_01_1_1.mp420161026T1447176867_scale1.5_leftdown.jpg',...
    'VTS_01_1_1.mp420161026T144542941_scale1.5_center.jpg', ...
    'VTS_01_1_1.mp420161026T1446112770_scale1.25_rightdown.jpg'];

for traini=1:numel(trainidx)%for each training image
    fileidx=trainidx(traini);
    filename=namelistcell{fileidx};
    
%     if(exist([path '/foreground/' filename],'file'))
%         I=single(imread([path '/foreground/' filename]));
%     elseif(exist([path '/background/' filename],'file'))
%         I=single(imread([path '/background/' filename]));
    if(exist([path '/' filename],'file'))
        I=single(imread([path '/' filename]));
    else
        msgbox('Aumentation no image exist!');
    end
    
    if(rem(traini,100)==0)
        disp(['scale num:' num2str(traini)]);
    end
    
    gtbox_aug=gtbox{fileidx};
    
    for scalei=1:numel(scalefactor)%for each scale
        scale=scalefactor(scalei);
        h_afterscale=h_resize*scale;
        w_afterscale=w_resize*scale;
        img_resize_aug=imresize(I,[h_afterscale,w_afterscale]);
        
        lefttoprect=[1,1,w_resize-1,h_resize-1];
        righttoprect=[w_afterscale-w_resize+1,1,w_resize-1,h_resize-1];
        leftdownrect=[1,h_afterscale-h_resize+1,w_resize-1,h_resize-1];
        rightdownrect=[w_afterscale-w_resize+1,h_afterscale-h_resize+1,w_resize-1,h_resize-1];
        centerrect=[(h_afterscale-h_resize)/2+1,(w_afterscale-w_resize)/2+1,w_resize-1,h_resize-1];
        
        %show rect
        %         figure;imshow(img_resize_aug);
        %         hold on;
        %         rectangle('Position',lefttoprect,'EdgeColor',randi([1 255],1,3)/255);
        %         rectangle('Position',righttoprect,'EdgeColor',randi([1 255],1,3)/255);
        %         rectangle('Position',leftdownrect,'EdgeColor',randi([1 255],1,3)/255);
        %         rectangle('Position',rightdownrect,'EdgeColor',randi([1 255],1,3)/255);
        %         rectangle('Position',centerrect,'EdgeColor',randi([1 255],1,3)/255);
        %
        %         hold off;
        
        imgcrop_lefttop=imcrop(img_resize_aug,lefttoprect);
        imgcrop_righttop=imcrop(img_resize_aug,righttoprect);
        imgcrop_leftdown=imcrop(img_resize_aug,leftdownrect);
        imgcrop_rightdown=imcrop(img_resize_aug,rightdownrect);
        imgcrop_center=imcrop(img_resize_aug,centerrect);
        
        %scale groundtruth box
        
        %check groundtruth box
        %         figure;imshow(I);hold on;
        %         rectangle('Position',[gtbox_aug(1) gtbox_aug(2) gtbox_aug(3)-gtbox_aug(1) gtbox_aug(4)-gtbox_aug(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        gtbox_rescale_aug=round(gtbox_aug*scale);%gtbox_rescale_aug and gtbox_aug are defined by topleft and rightdown point.should convert to [topleftpoint w h] if neccessary
        gtbox_rescale_aug_wh=[gtbox_rescale_aug(1) gtbox_rescale_aug(2) gtbox_rescale_aug(3)-gtbox_rescale_aug(1)+1 gtbox_rescale_aug(4)-gtbox_rescale_aug(2)+1];
        %         figure;imshow(img_resize_aug);hold on;
        %         rectangle('Position',[gtbox_rescale_aug(1) gtbox_rescale_aug(2) gtbox_rescale_aug(3)-gtbox_rescale_aug(1) gtbox_rescale_aug(4)-gtbox_rescale_aug(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        
        %righttop case:
        box_intersect=BBoxIntersect(gtbox_rescale_aug_wh,righttoprect);
        box_intersect_updownpoint=[box_intersect(1),box_intersect(2),box_intersect(1)+box_intersect(3)-1,box_intersect(2)+box_intersect(4)-1];
        
        %disp(['gtbox_rescale_aug_wh:' class(gtbox_rescale_aug_wh) 'righttoprect:' class(righttoprect) ]);
        overlapRatio = bboxOverlapRatio(gtbox_rescale_aug_wh, righttoprect,'Min');
        
        %coordinate transform
        box_intersect_updownpoint([1 3])=box_intersect_updownpoint([1 3])-righttoprect(1)+1;
        box_intersect_updownpoint([2 4])=box_intersect_updownpoint([2 4])-righttoprect(2)+1;
        
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_scale' num2str(scale) '_righttop' '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        
%         if(~isempty(strfind(probname,name_aug)))
%             name_aug
%         end
        
        
        
        box = Selectivesearchwrapper(imgcrop_righttop);
        boxesall{end+1}=box;
        %imgdata_aug=cat(4,imgdata_aug,imgcrop_righttop);
        
        if(overlapRatio<0.1)%<thresh labeled by background
            
            gtbox{end+1}=[1 1 w_resize h_resize];
            
        else%labeled by foreground
            
            gtbox{end+1}=box_intersect_updownpoint;
        end
        
        %save
        imwrite(im2double(imgcrop_righttop)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((imgcrop_righttop(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((imgcrop_righttop(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((imgcrop_righttop(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        
        %lefttop case:
        box_intersect=BBoxIntersect(gtbox_rescale_aug_wh,lefttoprect);
        box_intersect_updownpoint=[box_intersect(1),box_intersect(2),box_intersect(1)+box_intersect(3)-1,box_intersect(2)+box_intersect(4)-1];
        overlapRatio = bboxOverlapRatio(gtbox_rescale_aug_wh, lefttoprect,'Min');
        %coordinate transform
        box_intersect_updownpoint([1 3])=box_intersect_updownpoint([1 3])-lefttoprect(1)+1;
        box_intersect_updownpoint([2 4])=box_intersect_updownpoint([2 4])-lefttoprect(2)+1;
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_scale' num2str(scale) '_lefttop' '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        
%         if(~isempty(strfind(probname,name_aug)))
%             name_aug
%         end
        
        box = Selectivesearchwrapper(imgcrop_lefttop);
        boxesall{end+1}=box;
        
        %imgdata_aug=cat(4,imgdata_aug,imgcrop_lefttop);
        if(overlapRatio<0.1)%<thresh labeled by background
            
            gtbox{end+1}=[1 1 w_resize h_resize];
            
        else%labeled by foreground
            
            gtbox{end+1}=box_intersect_updownpoint;
        end
        
        %save
        imwrite(im2double(imgcrop_lefttop)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((imgcrop_lefttop(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((imgcrop_lefttop(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((imgcrop_lefttop(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        
        %         figure;imshow(imgcrop_lefttop);
        %         hold on;
        %         rectangle('Position',[gtbox{end}(1) gtbox{end}(2) gtbox{end}(3)-gtbox{end}(1) gtbox{end}(4)-gtbox{end}(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        %
        
        
        %leftdown case:
        box_intersect=BBoxIntersect(gtbox_rescale_aug_wh,leftdownrect);
        box_intersect_updownpoint=[box_intersect(1),box_intersect(2),box_intersect(1)+box_intersect(3)-1,box_intersect(2)+box_intersect(4)-1];
        overlapRatio = bboxOverlapRatio(gtbox_rescale_aug_wh, leftdownrect,'Min');
        
        %coordinate transform
        box_intersect_updownpoint([1 3])=box_intersect_updownpoint([1 3])-leftdownrect(1)+1;
        box_intersect_updownpoint([2 4])=box_intersect_updownpoint([2 4])-leftdownrect(2)+1;
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_scale' num2str(scale) '_leftdown' '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        
        
%          if(~isempty(strfind(probname,name_aug)))
%             name_aug
%         end  
            
        box = Selectivesearchwrapper(imgcrop_leftdown);
        boxesall{end+1}=box;
        
        %imgdata_aug=cat(4,imgdata_aug,imgcrop_leftdown);
        if(overlapRatio<0.1)%<thresh labeled by background
            
            gtbox{end+1}=[1 1 w_resize h_resize];
            
        else%labeled by foreground
            
            gtbox{end+1}=box_intersect_updownpoint;
        end
        
        %save
        imwrite(im2double(imgcrop_leftdown)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((imgcrop_leftdown(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((imgcrop_leftdown(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((imgcrop_leftdown(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        %         figure;imshow(imgcrop_leftdown);
        %         hold on;
        %         rectangle('Position',[gtbox{end}(1) gtbox{end}(2) gtbox{end}(3)-gtbox{end}(1) gtbox{end}(4)-gtbox{end}(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        
        
        %rightdown case:
        box_intersect=BBoxIntersect(gtbox_rescale_aug_wh,rightdownrect);
        box_intersect_updownpoint=[box_intersect(1),box_intersect(2),box_intersect(1)+box_intersect(3)-1,box_intersect(2)+box_intersect(4)-1];
        overlapRatio = bboxOverlapRatio(gtbox_rescale_aug_wh, rightdownrect,'Min');
        
        %coordinate transform
        box_intersect_updownpoint([1 3])=box_intersect_updownpoint([1 3])-rightdownrect(1)+1;
        box_intersect_updownpoint([2 4])=box_intersect_updownpoint([2 4])-rightdownrect(2)+1;
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_scale' num2str(scale) '_rightdown' '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        
%         if(~isempty(strfind(probname,name_aug)))
%             name_aug
%         end
        
        box = Selectivesearchwrapper(imgcrop_rightdown);
        boxesall{end+1}=box;
        
        %imgdata_aug=cat(4,imgdata_aug,imgcrop_rightdown);
        if(overlapRatio<0.1)%<thresh labeled by background
            
            gtbox{end+1}=[1 1 w_resize h_resize];
            
        else%labeled by foreground
            
            gtbox{end+1}=box_intersect_updownpoint;
        end
        
        %save
        imwrite(im2double(imgcrop_rightdown)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((imgcrop_rightdown(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((imgcrop_rightdown(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((imgcrop_rightdown(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        
        %         figure;imshow(imgcrop_rightdown);
        %         hold on;
        %         rectangle('Position',[gtbox{end}(1) gtbox{end}(2) gtbox{end}(3)-gtbox{end}(1) gtbox{end}(4)-gtbox{end}(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        
        
        %center case:
        box_intersect=BBoxIntersect(gtbox_rescale_aug_wh,centerrect);
        box_intersect_updownpoint=[box_intersect(1),box_intersect(2),box_intersect(1)+box_intersect(3)-1,box_intersect(2)+box_intersect(4)-1];
        overlapRatio = bboxOverlapRatio(gtbox_rescale_aug_wh, centerrect,'Min');
        
        %coordinate transform
        box_intersect_updownpoint([1 3])=box_intersect_updownpoint([1 3])-centerrect(1)+1;
        box_intersect_updownpoint([2 4])=box_intersect_updownpoint([2 4])-centerrect(2)+1;
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_scale' num2str(scale) '_center' '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        
%         if(~isempty(strfind(probname,name_aug)))
%             name_aug
%         end
        
        box = Selectivesearchwrapper(imgcrop_center);
        boxesall{end+1}=box;
        
        %imgdata_aug=cat(4,imgdata_aug,imgcrop_center);
        if(overlapRatio<0.1)%<thresh labeled by background
            
            gtbox{end+1}=[1 1 w_resize h_resize];
            
        else%labeled by foreground
            
            gtbox{end+1}=box_intersect_updownpoint;
        end
        %         if(strcmp(name_aug,'VTS_01_1_1.mp420161026T1447046087_scale1.5_center.jpg'))
        %             name_aug
        %         end
        
        %save
        imwrite(im2double(imgcrop_center)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((imgcrop_center(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((imgcrop_center(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((imgcrop_center(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        %         figure;imshow(imgcrop_center);
        %         hold on;
        %         rectangle('Position',[gtbox{end}(1) gtbox{end}(2) gtbox{end}(3)-gtbox{end}(1) gtbox{end}(4)-gtbox{end}(2)],'EdgeColor',randi([1 255],1,3)/255);
        %         hold off;
        
        
        
        
    end
end


num_afteraug=numel(namelistcell);
aug_num=num_afteraug-num_beforeaug;
%calculate mean
% imgdataR=imgdata_aug(:,:,1,:);
% imgdataG=imgdata_aug(:,:,2,:);
% imgdataB=imgdata_aug(:,:,3,:);
% 
% imgdataRmean=mean(mean(mean(imgdataR)));
% imgdataGmean=mean(mean(mean(imgdataG)));
% imgdataBmean=mean(mean(mean(imgdataB)));
% 
% Scalemean_aug=struct('num',aug_num,'rmean',imgdataRmean,'gmean',imgdataGmean...
%     ,'bmean',imgdataBmean);

Scalemean_aug=struct('num',aug_num,'rmean',meanR,'gmean',meanG...
    ,'bmean',meanB);
%delete(gcp);


namelistcell=reshape(namelistcell,1,numel(namelistcell));
gtbox=reshape(gtbox,1,numel(gtbox));
gtlabel=reshape(gtlabel,1,numel(gtlabel));
boxesall=reshape(boxesall,1,numel(boxesall));
set=reshape(set,numel(set),1);
imgsize=reshape(imgsize,numel(set),2);


disp('scale aug finish...');   
end

