function net = fast_rcnn_init(varargin)


opts.piecewise = 1;
opts.modelPath = fullfile('data', 'models','mylenet80x64.mat');
opts.imdbpath=[];
opts = vl_argparse(opts, varargin) ;
display(opts) ;

% Load an imagenet pre-trained cnn model.
net = load(opts.modelPath);
net = vl_simplenn_tidy(net.net);


% Change loss for FC layers.
nCls=2;
myROIpoolsize=[2 2];
lastfc=find(cellfun(@(a) strcmp(a.name, 'layer13'), net.layers)==1);
net.layers{lastfc}.name = 'predcls';
net.layers{lastfc}.weights{1} = 0.01 * randn(myROIpoolsize(1),myROIpoolsize(2),size(net.layers{lastfc}.weights{1},3),nCls,'single');
net.layers{lastfc}.weights{2} = zeros(1, nCls, 'single');

depth_Roipooloutput=size(net.layers{lastfc}.weights{1},3);

% Skip pool5.
%skip global pool
globalpool=find(cellfun(@(a) strcmp(a.name, 'layer12'), net.layers)==1);
net.layers = net.layers([1:globalpool-1,globalpool+1:end-1]);


% Convert to DagNN.
net = dagnn.DagNN.fromSimpleNN(net, 'canonicalNames', true) ;

% Add ROIPooling layer.

mylastrelu=find(arrayfun(@(a) strcmp(a.name, 'layer11'), net.layers)==1);
%ADDLAYER  Adds a layer to a DagNN
%   ADDLAYER(NAME, LAYER, INPUTS, OUTPUTS, PARAMS)
net.addLayer('roipool', dagnn.ROIPooling('method','max','transform',1/16,...
     'subdivisions',[2,2],'flatten',0), ...
     {net.layers(mylastrelu).outputs{1},'rois'}, 'xRP');%last two parameters are input and output
 

predclslayer=(arrayfun(@(a) strcmp(a.name, 'predcls'), net.layers)==1);
net.layers(predclslayer).inputs{1}='xRP';

% Add softmax loss layer.
net.addLayer('losscls',dagnn.Loss(), ...
  {net.layers(predclslayer).outputs{1},'label'}, ...
  'losscls',{});

net.addLayer('predbbox',dagnn.Conv('size',[1 1 myROIpoolsize(1)*myROIpoolsize(2)*depth_Roipooloutput 4*nCls],'hasBias', true), ...
    'xRP','predbbox',{'predbboxf','predbboxb'});

 net.params(end-1).value = 0.001 * randn(myROIpoolsize(1),myROIpoolsize(2),depth_Roipooloutput,4*nCls,'single');
 net.params(end).value = zeros(1,4*nCls,'single');

%add loss box

 net.addLayer('lossbbox',dagnn.LossSmoothL1(), ...
    {'predbbox','targets','instance_weights'}, ...
    'lossbbox',{});

net.rebuild();

% No decay for bias and set learning rate to 2
for i=2:2:numel(net.params)
  net.params(i).weightDecay = 0;
  net.params(i).learningRate = 2;
end

% Change image-mean as in fast-rcnn code
load(opts.imdbpath);
RGBmean=[images.RGBmean.Rmean,images.RGBmean.Gmean,images.RGBmean.Bmean];
net.meta.normalization.averageImage = ...
  reshape(RGBmean,[1 1 3]);



net.meta.normalization.interpolation = 'bilinear';

net.meta.classes.name = {'foreground'};  
net.meta.classes.description = {};
