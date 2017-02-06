function [ boxes ] = Selectivesearchwrapper( im )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Parameters. Note that this controls the number of hierarchical
% segmentations which are combined.
addpath('../SelectiveSearchCodeIJCV');
addpath('../SelectiveSearchCodeIJCV/Dependencies');

colorTypes = {'Hsv', 'Lab', 'RGI', 'H', 'Intensity'};
colorType = colorTypes{1}; % Single color space for demo

% Here you specify which similarity functions to use in merging
simFunctionHandles = {@SSSimColourTextureSizeFillOrig, @SSSimTextureSizeFill, @SSSimBoxFillOrig, @SSSimSize};
simFunctionHandles = simFunctionHandles(1:2); % Two different merging strategies

% Thresholds for the Felzenszwalb and Huttenlocher segmentation algorithm.
% Note that by default, we set minSize = k, and sigma = 0.8.
k = 200; % controls size of segments of initial segmentation. 
minSize = k;
sigma = 0.8;




[boxes blobIndIm blobBoxes hierarchy] = Image2HierarchicalGrouping(im, sigma, k, minSize, colorType, simFunctionHandles);
boxes = BoxRemoveDuplicates(boxes);

end

