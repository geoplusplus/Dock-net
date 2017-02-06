function [ hsvmean_aug,namelistcell_afteraug,gtbox_afteraug,gtlabel_afteraug,set_afteraug,imgsize_afteraug,boxesall_afteraug ] = ImghsvAug( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall,imgdata_aug )


train_idx=find(set==1);
batch_num=1;
num_perbatch=floor(numel(train_idx)/batch_num);
batch_idx_cell=cell(1,batch_num);


hsvmean_aug_batch=cell(1,batch_num);
namelistcell_batch=cell(batch_num,1);
gtbox_batch=cell(batch_num,1);
gtlabel_batch=cell(batch_num,1);
set_batch=cell(batch_num,1);
imgsize_batch=cell(batch_num,1);
boxesall_batch=cell(batch_num,1);

namelistcell_afteraug={};
gtbox_afteraug={};
gtlabel_afteraug={};
set_afteraug=[];
imgsize_afteraug=[];
boxesall_afteraug={};


for i=1:batch_num
    if(i<batch_num)
    batch_idx_cell{i}=[(i-1)*num_perbatch+1:i*num_perbatch];
    else%last group
        batch_idx_cell{i}=[(i-1)*num_perbatch+1:numel(train_idx)];
    end
end





%[ hsvmean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImghsvAug_batch( path,namelistcell(batch_idx_cell{1}),gtbox(batch_idx_cell{1}),gtlabel(batch_idx_cell{1}),set(batch_idx_cell{1}),w_resize,h_resize,boxesall(batch_idx_cell{1}),imgsize(batch_idx_cell{1},:) );
for i=1:batch_num
    [ hsvmean_aug_batch{i},namelistcell_batch{i},gtbox_batch{i},gtlabel_batch{i},set_batch{i},imgsize_batch{i},boxesall_batch{i} ] = ImghsvAug_batch( path,namelistcell(batch_idx_cell{i}),gtbox(batch_idx_cell{i}),gtlabel(batch_idx_cell{i}),set(batch_idx_cell{i}),w_resize,h_resize,boxesall(batch_idx_cell{i}),imgsize(batch_idx_cell{i},:) );

end

%combine result togethor
for i=1:batch_num
    %namelistcell_afteraug(end+1)=namelistcell_batch(i);
    namelistcell_afteraug=cat(2,namelistcell_afteraug,namelistcell_batch{i});
    
    gtbox_afteraug=cat(2,gtbox_afteraug,gtbox_batch{i});
    gtlabel_afteraug=cat(2,gtlabel_afteraug,gtlabel_batch{i});
    set_afteraug=cat(1,set_afteraug,set_batch{i});
    imgsize_afteraug=[imgsize_afteraug;imgsize_batch{i}];
    boxesall_afteraug=cat(2,boxesall_afteraug,boxesall_batch{i});
end

%cal rgbmean
totalR=0;
totalG=0;
totalB=0;
meanR=0;
meanG=0;
meanB=0;

total_imgnum=0;
for i=1:batch_num
%     totalR=totalR+hsvmean_aug_batch{i}.rmean*hsvmean_aug_batch{i}.num;
%     totalG=totalG+hsvmean_aug_batch{i}.gmean*hsvmean_aug_batch{i}.num;
%     totalB=totalB+hsvmean_aug_batch{i}.bmean*hsvmean_aug_batch{i}.num;
%     total_imgnum=total_imgnum+hsvmean_aug_batch{i}.num;
    meanR=(meanR*total_imgnum+hsvmean_aug_batch{i}.rmean*hsvmean_aug_batch{i}.num)...
        /(total_imgnum+hsvmean_aug_batch{i}.num);
    meanG=(meanG*total_imgnum+hsvmean_aug_batch{i}.gmean*hsvmean_aug_batch{i}.num)...
        /(total_imgnum+hsvmean_aug_batch{i}.num);
    meanB=(meanB*total_imgnum+hsvmean_aug_batch{i}.bmean*hsvmean_aug_batch{i}.num)...
        /(total_imgnum+hsvmean_aug_batch{i}.num);
    total_imgnum=total_imgnum+hsvmean_aug_batch{i}.num;
    
    
end

% meanR=totalR/total_imgnum;
% meanG=totalG/total_imgnum;
% meanB=totalB/total_imgnum;

hsvmean_aug=struct('num',total_imgnum,'rmean',meanR,'gmean',meanG...
    ,'bmean',meanB);


end

