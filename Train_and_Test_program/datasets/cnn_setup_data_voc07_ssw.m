function imdb = cnn_setup_data_voc07_ssw(varargin)
%CNN_SETUP_DATE_VOC07_SSW  Setup PASCAL VOC 2007 data with precomputed SSW proposals
%
% Copyright (C) 2016 Hakan Bilen.
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).

opts.sswDir = fullfile('data','SSW') ;
opts.dataDir = 'data' ;
%opts.addFlipped = true ;
opts.addFlipped = 0;
opts.useDifficult = true ;
opts.fgThresh = 0.5 ;
opts.bgThreshHi = 0.5 ;
opts.bgThreshLo = 0.1 ;
opts.imdbpath=[];
opts = vl_argparse(opts, varargin) ;

%% Get selective search windows
% files = {...
%   'SelectiveSearchVOC2007trainval.mat', ...
%   'SelectiveSearchVOC2007test.mat'} ;

% files = {...
%   'SelectiveSearchDockingTrain161231strongintensity.mat', ...
%   'SelectiveSearchDockingTest161231strongintensity.mat'} ;
% files = {...
%   'SelectiveSearchDockingTrain161219jitter10perimg_aug.mat', ...
%   'SelectiveSearchDockingTest161219jitter10perimg_aug.mat'} ;
files = {...
  'proposals_train.mat', ...
  'proposals_test.mat'} ;

if ~exist(opts.sswDir, 'dir')
  mkdir(opts.sswDir) ;
end

for i=1:numel(files)
  outPath = fullfile(opts.sswDir, files{i}) ;
  if ~exist(outPath, 'file')
    url = sprintf('http://koen.me/research/downloads/%s',files{i}) ;
    fprintf('Downloading %s to %s\n', url, outPath) ;
    urlwrite(url,outPath) ;
  end
end

%% Get image names and gt boxes.
% imdb = cnn_setup_data_voc07(...
%   'dataDir', opts.dataDir, ...
%   'useDifficult', opts.useDifficult, ...
%   'addFlipped', opts.addFlipped) ;
%imdb=load('../../data/fast-rcnn-vgg16-pascal07/myimdb_size84m60_fastrcnn161107.mat');
imdb=load(opts.imdbpath);


%randomly display a image,my
randindex=randi([1,10000],1,100);




%% Load precomputed object proposals
train = load(fullfile(opts.sswDir, files{1})) ;
test = load(fullfile(opts.sswDir, files{2})) ;

% Check that all proposals are correctly matched to an image in imdb
%assert(isempty(...
%  setxor(vertcat(train.images,test.images), cellfun(@(x)x(1:6),imdb.images.name,'uniformoutput',0)))) ;
%assert(isempty(...
%  setxor(vertcat(train.images,test.images), cellfun(@(x)x(1:end),imdb.images.name,'uniformoutput',0)))) ;
opts.addFlipped=0;
if opts.addFlipped
  boxes = horzcat(train.boxes,train.boxes,test.boxes) ;
  imnames = vertcat(train.images,train.images,test.images) ;
else
  boxes = horzcat(train.boxes,test.boxes) ;
  imnames = vertcat(train.images,test.images) ;
end
%assert(numel(boxes)==numel(imdb.images.name)) ;





% Sort proposals by ascending image name, as this is also the order in imdb
 %imdb.images.name=sort(imdb.images.name);
 [imdb.images.name imdbnamei]=sort(imdb.images.name);
 [imnames,si] = sort(imnames);
 boxes = boxes(si);
 
 
 %mine161114
 tmpgtbox=imdb.boxes.gtbox;
 imdb.boxes.gtbox=imdb.boxes.gtbox(imdbnamei);
 imdb.boxes.gtlabel=imdb.boxes.gtlabel(imdbnamei);
 %imdb.boxes.flip=imdb.boxes.flip(imdbnamei);
 imdb.boxes.flip=zeros(numel(imdb.boxes.gtbox),1);%all flip is zero means do not flip any pic in this program
%  
%  %display bbox
% for i=1:50
% 
% display_I=imread([imdb.imageDir '/' imdb.images.name{randindex(i)}]);
% display_bbox_updownpoint=imdb.boxes.gtbox{randindex(i)}
% figure;imshow(display_I);
% hold on;
% rectangle('Position',[display_bbox_updownpoint(1:2) display_bbox_updownpoint(3)-display_bbox_updownpoint(1) display_bbox_updownpoint(4)-display_bbox_updownpoint(2)],'Edgecolor','r');
% hold off;
% end


% Transpose XY in proposals
for i=1:numel(boxes)
  boxes{i} = boxes{i}(:,[2 1 4 3]);
end

% Check boxes and find corresponding image
for i=1:numel(imdb.images.name)

  bbox = boxes{i};
  %assert(strcmp(imnames{i},imdb.images.name{i}(1:end-4)));
  
  assert(strcmp(imnames{i},imdb.images.name{i}(1:end)));
  assert(all(all(bbox(:,[1 2]) <= bbox(:,[3 4])))) ;
  assert(all(all(1 <= bbox & bsxfun(@le, bbox, imdb.images.size(i,[1 2 1 2]))))) ;

  % Flip the proposals if needed
  if imdb.boxes.flip(i)
    imageWidth = imdb.images.size(i,1) ;
    bbox(:,[3 1]) = imageWidth - bbox(:,[1 3]) + 1 ;
  end

  boxes{i} = bbox ;
end

% %randomly display a image
% for i=1:50
% randindex=randi([1,10000],1,1);
% display_I=imread([imdb.imageDir '/' imdb.images.name{randindex}]);
% display_bbox_updownpoint=imdb.boxes.gtbox{randindex}
% figure;imshow(display_I);
% hold on;
% rectangle('Position',[display_bbox_updownpoint(1:2) display_bbox_updownpoint(3)-display_bbox_updownpoint(1) display_bbox_updownpoint(4)-display_bbox_updownpoint(2)],'Edgecolor','r');
% hold off;
% end


imdb = attach_proposals(imdb,boxes,opts.fgThresh,opts.bgThreshHi,opts.bgThreshLo);
imdb = add_bboxreg_targets(imdb);

% 
% %randomly display a image
% 
% for i=1:50
% 
% display_I=imread([imdb.imageDir '/' imdb.images.name{randindex(i)}]);
% display_bbox_updownpoint=imdb.boxes.gtbox{randindex(i)}
% figure;imshow(display_I);
% hold on;
% rectangle('Position',[display_bbox_updownpoint(1:2) display_bbox_updownpoint(3)-display_bbox_updownpoint(1) display_bbox_updownpoint(4)-display_bbox_updownpoint(2)],'Edgecolor','r');
% hold off;
% end


if 0
  for i = 1:100
    for c = 1:21
      sel = find(imdb.boxes.plabel{i} == c) ;
      if isempty(sel), continue ; end
      im = imread(fullfile(imdb.imageDir, imdb.images.name{i})) ;
      if imdb.boxes.flip(i), im = fliplr(im) ; end
      pbox = imdb.boxes.pbox{i}(sel,:) ;
      clf ; bbox_draw(im, pbox) ;
      title(sprintf('Class %d', c)) ;
      keyboard
    end
  end
end
