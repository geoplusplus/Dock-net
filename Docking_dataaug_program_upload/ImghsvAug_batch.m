function [ hsvmean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImghsvAug_batch( path,namelistcell,gtbox,gtlabel,set,w_resize,h_resize,boxesall,imgsize )
%permutation is carried out in hsv space
disp('hsv aug start...');   
train_idx=find(set==1);
%img_data=[];
num_beforeaug=numel(namelistcell);

meanR=0;
meanG=0;
meanB=0;
cur_imgnum=0;

%each training image
for traini=1:numel(train_idx)
    fileidx=train_idx(traini);
    filename=namelistcell{fileidx};
    
    gtbox_aug=gtbox{fileidx};
    
    if(exist([path '/' filename],'file'))
        I=single(imread([path '/' filename]));
    else
        msgbox('Aumentation no image exist!');
    end
    
    if(rem(traini,100)==0)
        traini
    end
    
    %generate permutation
    uh=0;sigmah=0.01;
    us=0;sigmas=0.2;
    uv=0;sigmav=0.2;
    %num_per=10;
    num_per=1;
    
    rh=normrnd(uh,sigmah,[1 num_per]);
    rh(find(rh>1))=1;
    rh(find(rh<-1))=-1;
    rs=normrnd(us,sigmas,[1 num_per]);
    rs(find(rs>1))=1;
    rs(find(rs<-1))=-1;
    rv=normrnd(uv,sigmav,[1 num_per]);
    rv(find(rv>1))=1;
    rv(find(rv<-1))=-1;
    
    for peri=1:num_per
        img_hsv=rgb2hsv(I);
        img_hsv(:,:,1)=img_hsv(:,:,1)+rh(peri);%hue
        img_hsv(:,:,2)=img_hsv(:,:,2)+rs(peri);%s
        img_hsv(:,:,3)=img_hsv(:,:,3)+rv(peri);%v
        img_rgb=hsv2rgb(img_hsv);%back to rgb after permutation
        
        
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_hper' num2str(round(rh(peri) / 0.001) * 0.001) ...
            '_sper' num2str(round(rs(peri) / 0.001) * 0.001)...
            '_vper' num2str(round(rv(peri) / 0.001) * 0.001)...
            '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        box = Selectivesearchwrapper(img_rgb);
        boxesall{end+1}=box;
        gtbox{end+1}=gtbox_aug;
        
        %img_data=cat(4,img_data,img_rgb);
        
        %save
        imwrite(im2double(img_rgb)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((img_rgb(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((img_rgb(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((img_rgb(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        
        
    end
    
    
    
    
end


num_afteraug=numel(namelistcell);
aug_num=num_afteraug-num_beforeaug;
% %calculate mean
% imgdataR=img_data(:,:,1,:);
% imgdataG=img_data(:,:,2,:);
% imgdataB=img_data(:,:,3,:);

% imgdataRmean=mean(mean(mean(imgdataR)));
% imgdataGmean=mean(mean(mean(imgdataG)));
% imgdataBmean=mean(mean(mean(imgdataB)));

% hsvmean_aug=struct('num',aug_num,'rmean',imgdataRmean,'gmean',imgdataGmean...
%     ,'bmean',imgdataBmean);
hsvmean_aug=struct('num',aug_num,'rmean',meanR,'gmean',meanG...
    ,'bmean',meanB);


namelistcell=reshape(namelistcell,1,numel(namelistcell));
gtbox=reshape(gtbox,1,numel(gtbox));
gtlabel=reshape(gtlabel,1,numel(gtlabel));
boxesall=reshape(boxesall,1,numel(boxesall));
set=reshape(set,numel(set),1);
imgsize=reshape(imgsize,numel(set),2);





disp('hsv aug end...');   

end

