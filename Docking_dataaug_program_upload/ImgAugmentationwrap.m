function [ mean_aug,namelistcell,gtbox,gtlabel,set,imgsize ,boxesall,flip] = ImgAugmentationwrap( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall)
%function for image augmentation
%   return value:
%                   imgdata:augmented images data
disp('In agumentation...');   
scalefactor=[1.25 1.5];
%scalefactor=[1.25];
tic

imgdata_aug=[];

[ Jittermean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImgJitterAug( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall);

[Scalemean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImgScaleAug( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,scalefactor,boxesall,imgdata_aug);

%[hsvmean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImghsvAug( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall,imgdata_aug );

[Flipmean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ,flip] = ImgFlipAug( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall,imgdata_aug);


%test
% mean_aug=Scalemean_aug;
% flip=1;
% %calculate mean

mean_aug.num=(Scalemean_aug.num +Jittermean_aug.num +Flipmean_aug.num);

mean_aug.rmean=(Scalemean_aug.rmean*Scalemean_aug.num + ...
Jittermean_aug.rmean*Jittermean_aug.num + ...
Flipmean_aug.rmean*Flipmean_aug.num)/mean_aug.num;


mean_aug.gmean=(Scalemean_aug.gmean*Scalemean_aug.num + ...
Jittermean_aug.gmean*Jittermean_aug.num + ...
Flipmean_aug.gmean*Flipmean_aug.num)/mean_aug.num;

mean_aug.bmean=(Scalemean_aug.bmean*Scalemean_aug.num + ...
Jittermean_aug.bmean*Jittermean_aug.num + ...
Flipmean_aug.bmean*Flipmean_aug.num)/mean_aug.num;

toc
end

