function [ Jittermean_aug,namelistcell,gtbox,gtlabel,set,imgsize,boxesall ] = ImgJitterAug_batch( path,namelistcell,gtbox,gtlabel,set,imgsize,w_resize,h_resize,boxesall)

%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
disp('jitter aug start...');

%parpool('local',6);
%imgdata_aug=[];

trainidx=find(set==1);
%imgdata_aug=[];
num_beforeaug=numel(namelistcell);

meanR=0;
meanG=0;
meanB=0;
cur_imgnum=0;

num_jitter_perimg=10;% jitter num for each img


for traini=1:numel(trainidx)%for each training image
    fileidx=trainidx(traini);
    filename=namelistcell{fileidx};
    
    %     if(exist([path '/foreground/' filename],'file'))
    %         I=single(imread([path '/foreground/' filename]));
    %         Iresize=imresize(I,[h_resize,w_resize]);
    %     elseif(exist([path '/background/' filename],'file'))
    %         I=single(imread([path '/background/' filename]));
    %         Iresize=imresize(I,[h_resize,w_resize]);
    if(exist([path '/' filename],'file'))
        I=single(imread([path '/' filename]));
        Iresize=imresize(I,[h_resize,w_resize]);
    else
        msgbox('Aumentation no image exist!');
    end
    
    if(rem(traini,100)==0)
        disp(['jitter num:' num2str(traini)]);
    end
    
    
    gtbox_aug=gtbox{fileidx};
    
    for jitteri=1:num_jitter_perimg
        Ijitter=ColorJitterPCA(Iresize,0,0.01);
        gtlabel{end+1}=1;
        name_aug=[filename(1:end-4) '_jitter' num2str(jitteri)  '.jpg'];
        namelistcell{end+1}=name_aug;
        set(end+1)=1;
        imgsize(end+1,:)=[w_resize,h_resize];
        
        box = Selectivesearchwrapper(Ijitter);
        boxesall{end+1}=box;
        
        %traini
        
        gtbox{end+1}=gtbox_aug;
        
        %save
        tmpfilename=[path '/' name_aug];
        fid = fopen(tmpfilename, 'a');
        if (fid == -1)
            error(message('MATLAB:imagesci:imwrite:fileOpen', tmpfilename));
        end
        fclose(fid);
        imwrite(im2double(Ijitter)/255,[path '/' name_aug],'jpg');
        
        cur_imgnum=cur_imgnum+1;
        meanR=mean(mean(mean((Ijitter(:,:,1)+(meanR*(cur_imgnum-1)))/cur_imgnum)));
        meanG=mean(mean(mean((Ijitter(:,:,2)+(meanG*(cur_imgnum-1)))/cur_imgnum)));
        meanB=mean(mean(mean((Ijitter(:,:,3)+(meanB*(cur_imgnum-1)))/cur_imgnum)));
        
    end
    
    
    
    
end




num_afteraug=numel(namelistcell);
aug_num=num_afteraug-num_beforeaug;


Jittermean_aug=struct('num',aug_num,'rmean',meanR,'gmean',meanG...
    ,'bmean',meanB);
%delete(gcp);


namelistcell=reshape(namelistcell,1,numel(namelistcell));
gtbox=reshape(gtbox,1,numel(gtbox));
gtlabel=reshape(gtlabel,1,numel(gtlabel));
boxesall=reshape(boxesall,1,numel(boxesall));
set=reshape(set,numel(set),1);
imgsize=reshape(imgsize,numel(set),2);


disp('jitter aug finish...');

end

