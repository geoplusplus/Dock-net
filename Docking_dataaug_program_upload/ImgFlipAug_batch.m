function [ Flipmean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall,flip] = ImgFlipAug_batch( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
disp('flip aug start...');

train_idx=find(set==1);
flip=zeros(numel(train_idx),1);
flip_idx=randperm(numel(train_idx));
flipratio=0.5;
%flipratio=1;
flipnum=flipratio*numel(train_idx);
flip(flip_idx(1:flipnum))=1;

%randshowidx=randi([1,numel(train_idx)],1,50);

num_beforeaug=numel(namelistcell);
%imgdata_aug=[];

meanR=0;
meanG=0;
meanB=0;
cur_imgnum=0;
for flipi=1:flipnum
    flip_cur_idx=flip_idx(flipi);
    filename=namelistcell{flip_cur_idx};
    if(exist([path '/' filename],'file'))
        I=single(imread([path '/' filename]));
    else
        msgbox('Aumentation no image exist!');
    end
    Iflip=flipdim(I,2);
    %     imgMirror = flipdim(img,2);      %# Flips the columns, making a
    %     mirror image
    % imgUpsideDown = flipdim(img,1);  %# Flips the rows, making an upside-down
    % image
    
    
    
    
    gtlabel{end+1}=gtlabel{flip_cur_idx};
    name_aug=[filename(1:end-4) '_leftrightflip' '.jpg'];
    namelistcell{end+1}=name_aug;
    set(end+1)=1;
    imgsize(end+1,:)=[w_resize,h_resize];
    
    box = Selectivesearchwrapper(Iflip);
    boxesall{end+1}=box;
    %imgdata_aug=cat(4,imgdata_aug,Iflip);
    gtbox{end+1}=flipbox(gtbox{flip_cur_idx},w_resize,h_resize);
    
    %save flipped images
    imwrite(im2double(Iflip)/255,[path '/' name_aug],'jpg');
    
    cur_imgnum=cur_imgnum+1;
    meanR=mean(mean(mean((Iflip(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
    meanG=mean(mean(mean((Iflip(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
    meanB=mean(mean(mean((Iflip(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
    %     if(ismember(flip_cur_idx,randshowidx))
    %     drawbox=[gtbox{end}(1) gtbox{end}(2) gtbox{end}(3)-gtbox{end}(1) gtbox{end}(4)-gtbox{end}(2)];
    %     figure;imshow(Iflip/255);
    %     hold on;
    %     rectangle('Position',drawbox,'EdgeColor','r');
    %     hold off;
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

Flipmean_aug=struct('num',aug_num,'rmean',meanR,'gmean',meanG...
    ,'bmean',meanB);


namelistcell=reshape(namelistcell,1,numel(namelistcell));
gtbox=reshape(gtbox,1,numel(gtbox));
gtlabel=reshape(gtlabel,1,numel(gtlabel));
boxesall=reshape(boxesall,1,numel(boxesall));
set=reshape(set,numel(set),1);
imgsize=reshape(imgsize,numel(set),2);
flip=reshape(flip,numel(flip),1);

disp('flip aug end...');
end

