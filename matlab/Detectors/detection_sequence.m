clear; clc; close all;

load('INRIA/inriaperson_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
%model.vis();

%path = 'OneLeaveShop1cor/';
path = 'OneLeaveShop1front/';

jpeg_list = dir(path);
jpeg_list = jpeg_list(3:end);

N = size(jpeg_list,1);

detections = [];

for i=1:N
    
    im_name = jpeg_list(i).name;
    im = imread(im_name);
    
    [ds, bs] = imgdetect(im, model, -0.5);
    
    if isempty(bs)
        continue;
    end
    
    top = nms(ds, 0.5);
    %top = top(1:min(length(top), 6));
    ds = ds(top, :);
    bs = bs(top, :);
    
    if model.type == model_types.Grammar
        bs = [ds(:,1:4) bs];
    end
    
    if model.type == model_types.MixStar
        % get bounding boxes
        bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
        bbox = clipboxes(im, bbox);
        top = nms(bbox, 0.5);
        showboxes(im, bbox(top,:));
    end
    
    number_detections = size(bbox,1);
    bounding_box = zeros(size(bbox,1),size(bbox,1)-1);
    bounding_box(:,1) = bbox(:,1);
    bounding_box(:,2) = bbox(:,2);
    bounding_box(:,3) = bbox(:,3) - bbox(:,1);
    bounding_box(:,4) = bbox(:,4) - bbox(:,2);
    detections= [detections; [ones(number_detections,1)*i, bounding_box]];
    
end

