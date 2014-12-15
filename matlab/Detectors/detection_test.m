load('INRIA/inriaperson_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
            
im = imread('OneLeaveShop1front0118.jpg');
clf;
image(im);
axis equal; 
axis on;
title('input image');
disp('input image');
%disp('press any key to continue'); pause;
%disp('continuing...');

% load and display model
model.vis();
%disp([cls ' model visualization']);
%disp('press any key to continue'); pause;
%disp('continuing...');

% detect objects
tic;
[ds, bs] = imgdetect(im, model, -1);
toc;
top = nms(ds, 0.5);
top = top(1:min(length(top), 2));
ds = ds(top, :);
bs = bs(top, :);
clf;
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
showboxes(im, reduceboxes(model, bs));
title('detections');
disp('detections');
disp('press any key to continue'); pause;
disp('continuing...');

if model.type == model_types.MixStar
  % get bounding boxes
  bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
  bbox = clipboxes(im, bbox);
  top = nms(bbox, 0.5);
  clf;
  showboxes(im, bbox(top,:));
  title('predicted bounding boxes');
  disp('bounding boxes');
  disp('press any key to continue'); pause;
end

