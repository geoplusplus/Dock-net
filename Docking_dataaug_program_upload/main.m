%date:170202
%pth:please select the path of '/dockingdataset_170202_720m576_upload'
%selective search proposals,
%caution:!!names of selective search mat should be modified (images,boxes)!!!!
%%==================================================================================
clear all;
tic;
pth=uigetdir;%please select the path of '/dockingdataset_170202_720m576_upload'

w_resize=80;
h_resize=64;
scale_ratio=720/80;%attention!!!!!!! should be modified if change size
whitenData=0;
train_ratio=0.8;
imgdata=[];



foregroundpath=[pth '/foreground/'];
backgroundpath=[pth '/background/'];
forefiles=[dir([foregroundpath '/*.jpg'])];
backfiles=[dir([backgroundpath '/*.jpg'])];
txtfiles=[dir([foregroundpath '/*.txt'])];
forefilesn=numel(forefiles);
backfilesn=numel(backfiles);
txtfilesn=numel(txtfiles);

name=cell(forefilesn+backfilesn,1);
gtbox=cell(1,forefilesn+backfilesn);
gtlabel=cell(forefilesn+backfilesn,1);
boxesall=cell(1,forefilesn+backfilesn);


imgsize=zeros(forefilesn+backfilesn,2);
set=zeros(forefilesn+backfilesn,1);
data=single([]);
labels=[];

forefileList=cell(forefilesn,1);

backfileList=cell(backfilesn,1);
txtfileList=cell(txtfilesn,1);

disp('program start...');

if(forefilesn==0)
    disp('directroy is null');
end
for i=1:forefilesn
    forefileList{i}=forefiles(i).name;
end

for i=1:backfilesn
    backfileList{i}=backfiles(i).name;
end


for i=1:txtfilesn
    txtfileList{i}=txtfiles(i).name;
end



parfor i=1:forefilesn
    strtmp=forefiles(i).name ;
    filename=forefileList{i};
    txtfilename=[filename '.txt'];
    
    imf = imfinfo([foregroundpath filename]);
    
    I=imread([foregroundpath filename]);
    
    if(imf.Width~=w_resize||imf.Height~=h_resize)%if not resize,resize it
        
        I=imresize(I,[h_resize w_resize]);
        %imwrite(I,[foregroundpath filename],'jpg');
        
        imwrite(I,[foregroundpath '../' filename],'jpg');
        
        imf = imfinfo([foregroundpath filename]);
    end
    
    imgdata(:,:,:,i)=I;
    
    %achieve boundingbox using selective search
    box = Selectivesearchwrapper(I);
    boxesall{i}=box;
    
    imgsize(i,:)=[size(I,2),size(I,1)];
    name(i)=cellstr(strtmp);
    
    %read txt
    [fd,syserrmsg]=fopen([foregroundpath  txtfilename],'rt');
    line=fgetl(fd);
    
    orin_bbox=str2num(line);
    bbox_updownpoint=[orin_bbox(1:2),orin_bbox(1:2)+orin_bbox(3:4)];
    bbox_updownpoint=fix(bbox_updownpoint/scale_ratio) ;
    
    
    %make sure bbox valid
    if(bbox_updownpoint(1)<1)
        bbox_updownpoint(1)=1;
    end
    
    if(bbox_updownpoint(2)<1)
        bbox_updownpoint(2)=1;
    end
    
    if(bbox_updownpoint(3)>w_resize)
        bbox_updownpoint(3)=w_resize;
    end
    
    
    if(bbox_updownpoint(4)>h_resize)
        bbox_updownpoint(4)=h_resize;
    end
    
    gtbox{i}=bbox_updownpoint;
    gtlabel{i}=1;
    fclose(fd);
end

for i=1:backfilesn
    strtmp=backfiles(i).name ;
    filename=backfileList{i};
    imf = imfinfo([backgroundpath filename]);
    I=imread([backgroundpath filename]);
    if(imf.Width~=w_resize||imf.Height~=h_resize)%if not resize,resize it
        %I=imread([backgroundpath filename]);
        I=imresize(I,[h_resize w_resize]);
        %imwrite(I,[backgroundpath filename],'jpg');
        
        imwrite(I,[backgroundpath '../' filename],'jpg');
        
        imf = imfinfo([backgroundpath filename]);
    end
    
    imgdata(:,:,:,i+forefilesn)=I;
    
    %achieve boundingbox using selective search
    box = Selectivesearchwrapper(I);
    boxesall{i+forefilesn}=box;
    imgsize(i+forefilesn,:)=[size(I,2),size(I,1)];
    %name{i+forefilesn}=cellstr(strtmp);
    name(i+forefilesn)=cellstr(strtmp);
    gtbox{i+forefilesn}=[1 1 w_resize h_resize];
    %gtbox{i+forefilesn}=[1 1 2 2];%for background its
    gtlabel{i+forefilesn}=2;
    
end

classesnames=cell(1,1);
classesnames{1}=char('foreground');


classesdescription=cell(1,1);
classesdescription=classesnames;


foretrain_n=ceil(forefilesn*train_ratio);
fore_rand_idx=randperm(forefilesn);
set(fore_rand_idx(1:foretrain_n))=1;%1 for train
set(fore_rand_idx(foretrain_n+1:forefilesn))=3;%3 for test

backtrain_n=ceil(backfilesn*train_ratio);
back_rand_idx=randperm(backfilesn)+forefilesn;
set(back_rand_idx(1:backtrain_n))=1;
set(back_rand_idx(backtrain_n+1:backfilesn))=3;

%image num without augmentation
orin_trainnum=numel(find(set==1));
disp('origin finish...');

[mean_aug,name,gtbox,gtlabel,set,imgsize ,boxesall,flip] = ImgAugmentationwrap( pth,name,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall);


%selective search proposals,
%caution:!!names of selective search mat should be modified (images,boxes)!!!!================================================
train_idx=find(set==1);
traingtbox=cell(1,numel(train_idx));
names_images_sel_sear_train=cell(numel(train_idx),1);
for i=1:numel(train_idx)
    
    traingtbox{i}=boxesall{train_idx(i)};
    names_images_sel_sear_train{i}=name{train_idx(i)};
    
end

test_idx=find(set==3);
testgtbox=cell(1,numel(test_idx));
names_images_sel_sear_test=cell(numel(test_idx),1);
for i=1:numel(test_idx)
    testgtbox{i}=boxesall{test_idx(i)};
    names_images_sel_sear_test{i}=name{test_idx(i)};
end


imgdataR=imgdata(:,:,1,:);
imgdataG=imgdata(:,:,2,:);
imgdataB=imgdata(:,:,3,:);

imgdataRmean=mean(mean(mean(imgdataR)));
imgdataGmean=mean(mean(mean(imgdataG)));
imgdataBmean=mean(mean(mean(imgdataB)));

%plus augmentation
total_trainnum=orin_trainnum+mean_aug.num;
imgdataRmeantotoal=(imgdataRmean*orin_trainnum+mean_aug.rmean*mean_aug.num)/total_trainnum;
imgdataGmeantotoal=(imgdataGmean*orin_trainnum+mean_aug.gmean*mean_aug.num)/total_trainnum;
imgdataBmeantotoal=(imgdataBmean*orin_trainnum+mean_aug.bmean*mean_aug.num)/total_trainnum;

RGBmean=struct('Rmean',imgdataRmeantotoal,'Gmean',imgdataGmeantotoal,'Bmean',imgdataBmeantotoal);

save('tmp_proposals_train.mat','traingtbox','names_images_sel_sear_train');
save('tmp_proposals_test.mat','testgtbox','names_images_sel_sear_test');
%=========================================================================

%whitenData
if whitenData
    z = reshape(data,[],size(data,4)) ;
    W = z(:,set == 1)*z(:,set == 1)'/size(data,4);
    [V,D] = eig(W) ;
    % the scale is selected to approximately preserve the norm of W
    d2 = diag(D) ;
    en = sqrt(mean(d2)) ;
    z = V*diag(en./max(sqrt(d2), 10))*V'*z ;
    data = reshape(z, h_resize, w_resize, 3, []) ;
end


classes=struct('name',{classesnames},'description',{classesdescription});
imageDir=char(pth);
images=struct('name',{name},'size',imgsize,'set',set,'RGBmean',RGBmean);
boxes=struct('gtbox',{gtbox},'gtlabel',{gtlabel},'flip',flip);


%Check boundingbox
for i=1:30
    randindex=randi([1,numel(train_idx)],1,1);
    display_I=imread([pth '/' images.name{randindex}]);
    display_bbox_updownpoint=boxes.gtbox{randindex}
    figure;imshow(display_I);
    hold on;
    rectangle('Position',[display_bbox_updownpoint(1:2) display_bbox_updownpoint(3)-display_bbox_updownpoint(1) display_bbox_updownpoint(4)-display_bbox_updownpoint(2)],'Edgecolor','r');
    hold off;
    
end




%save('myimdb_size84m60_fastrcnn161219jitter10perimg_aug.mat','images','boxes','classes','imageDir');
save('docking_imdb.mat','images','boxes','classes','imageDir');
%change names
clear all;
load('tmp_proposals_train.mat');
boxes=traingtbox;
images=names_images_sel_sear_train;
save('proposals_train.mat','boxes','images');
clear all;
load('tmp_proposals_test.mat');
boxes=testgtbox;
images=names_images_sel_sear_test;
save('proposals_test.mat','boxes','images');
delete('tmp_proposals_train.mat');
delete('tmp_proposals_test.mat');



delete(gcp);
toc;
