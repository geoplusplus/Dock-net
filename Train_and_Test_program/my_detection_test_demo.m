function my_detection_test_demo(varargin)
%this function is used to run detection on test images in a file document
%date: 17.1.21
%the detection results will be saved in '../test_samples/results'


run(fullfile(fileparts(mfilename('fullpath')), ...
   'matlab', 'vl_setupnn.m')) ;

addpath(fullfile('bbox_functions'));

opts.modelPath = '' ;
opts.classes = {'foreground'} ;
opts.gpu = [] ;

opts.confThreshold = 0.01;

opts.nmsThreshold = 0.3 ;
%opts.nmsThreshold = 0 ;

opts = vl_argparse(opts, varargin) ;


opts.modelPath='../data/models/net-10.mat';
res_path='../test_samples/results/';


%test data path
pth='../test_samples/test_datasets';
forefiles=[dir([pth '/*.jpg'])];
forefilesn=numel(forefiles);
forefileList=cell(forefilesn,1);

for i=1:forefilesn
    forefileList{i}=forefiles(i).name;
end

% Load the network and put it in test mode.
net = load(opts.modelPath) ;
net = dagnn.DagNN.loadobj(net);
net.mode = 'test' ;

for testi=1:forefilesn
    filename=forefileList{testi};
 
    im=single(imread([pth '/' filename]));
    im=imresize(im,[64 80]);
    imo = im; % keep original image
    boxes=Selectivesearchwrapper(im);
    
    
    
    %170121 if boxes proposals are too big to be the whole image, delete it
    box_del_record=[];%record which col should be deleted
    for boxesi=1:size(boxes,1)%find invalid box
        if((boxes(boxesi,4)-boxes(boxesi,2)>size(im,2)-5)&&(boxes(boxesi,3)-boxes(boxesi,1)>size(im,1)-5))
            box_del_record=[box_del_record,boxesi];
        end
    end
    
    %delete invalid box
    boxes(box_del_record,:)=[];
    
    if(isempty(boxes))
        disp(['empty proposal in' filename]);
        f=figure;imshow(im/255);
        axis image;
        axis off;
        set(gcf, 'Color', 'white');
        set(gcf,'outerposition',get(0,'screensize'));
        %from figure axes to image
        F=getframe(gca);
        Image=frame2im(F);
        imwrite(Image,[res_path filename '.jpg']);
        close(f);
        continue;
    end
    
    % Transpose XY in proposals
    for i=1:size(boxes,1)
        boxes(i,:) = boxes(i,[2 1 4 3]);
    end
   
    
    boxes = single(boxes') + 1 ;
    boxeso = boxes - 1; % keep original boxes
    
    % Remove the average color from the input image.
    imNorm = bsxfun(@minus, im, net.meta.normalization.averageImage) ;
    
    % Convert boxes into ROIs by prepending the image index. There is only
    % one image in this batch.
    rois = [ones(1,size(boxes,2)) ; boxes] ;
    
    % Evaluate network either on CPU or GPU.
    if numel(opts.gpu) > 0
        gpuDevice(opts.gpu) ;
        imNorm = gpuArray(imNorm) ;
        rois = gpuArray(rois) ;
        net.move('gpu') ;
    end
    
    net.conserveMemory = false ;
    net.eval({'input', imNorm, 'rois', rois});
    
    % Extract class probabilities and  bounding box refinements
    
    probs = squeeze(gather(net.vars(net.getVarIndex('probcls')).value)) ;
    
    deltas = squeeze(gather(net.vars(net.getVarIndex('predbbox')).value)) ;
    
    % Visualize results for one class at a time
    for i = 1:numel(opts.classes)
        c = find(strcmp(opts.classes{i}, net.meta.classes.name)) ;
        cprobs = probs(c,:) ;
        cdeltas = deltas(4*(c-1)+(1:4),:)' ;
        cboxes = bbox_transform_inv(boxeso', cdeltas);
        cls_dets = [cboxes cprobs'] ;
        
        keep = bbox_nms(cls_dets, opts.nmsThreshold) ;
        cls_dets = cls_dets(keep, :) ;
        
        sel_boxes = find(cls_dets(:,end) >= opts.confThreshold);
       
        my_draw_detection_res(im, cls_dets(sel_boxes,:),filename,res_path);
       
    end
    
    
    
end

