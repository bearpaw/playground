function [pad_im, labelmaps] = gen_groundtruth(conf, imdata, issoft)
[~,name,~] = fileparts(imdata.im);
% pad_im = [];
% labelmaps = [];
% if strcmp(name, '000437398') == 0
%   return;
% end

% TODO:
%   add random crop
DEBUG = 0;
% if imdata.isflip == 1 && imdata.r_degree ~= 0
% DEBUG = 1;
% end
if ~exist('issoft', 'var')
  issoft = true;
end

radius = conf.radius;
context = conf.context;
sigma = conf.sigma;
stride = conf.stride;

pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];  % parent order (14 parts)

% -------- Read images and joints ---------
im = imresize( imreadx(imdata), imdata.scale);

joints = imdata.joints;
joints(:, 1:2) = joints(:, 1:2) * imdata.scale;

valid_id = find(joints(:,3)~=-1);
min_joints = round(min(joints(valid_id, :)));
max_joints = round(max(joints(valid_id, :)));

% --------- crop images with bounding box and padding bounding box 
crop_im = subarray(im, min_joints(2)-context, max_joints(2)+context, ...
  min_joints(1)-context, max_joints(1)+context, 0);

joints(:, 1) = joints(:, 1)-(min_joints(1)-context);
joints(:, 2) = joints(:, 2)-(min_joints(2)-context);

if DEBUG
showskeletons_joints(crop_im, joints, pa); hold on; pause; close;
end

% --------- padding cropped images to the norm size
[pad_im, joints] = padding_pose(crop_im, joints, conf.norm_height);
if DEBUG
  size(pad_im);
  showskeletons_joints(pad_im, joints, pa); hold on; pause; close;
end
% generate maps
maph = size(pad_im, 1)/stride;
mapw = size(pad_im, 2)/stride;
numjoints = size(imdata.joints, 1);
labelmaps = zeros(maph, mapw, numjoints);

for c = 1:numjoints
  if joints(c, 3) ~= -1
    x = round(joints(c, 1))/stride;
    y = round(joints(c, 2))/stride;
    
    [softmap, hardmap] = ...
      gen_gaussian_map(maph, mapw, radius/stride, sigma, x, y, 0);
    if issoft
      labelmaps(:,:,c) = softmap;
    else
      labelmaps(:,:,c) = hardmap;
    end
    if DEBUG
      show_mask(pad_im, ...
        imresize(labelmaps(:,:,c), [size(pad_im, 1) size(pad_im,2)]), 0.5);
    end
    
  end
end
% stride = conf.stride;
% labelmaps = imresize(labelmaps, [maph/stride, mapw/stride], 'nearest');
% % DEBUG
% for c = 1:numjoints
%     clc; imagesc(labelmaps(:,:,c)); pause; close;
% end

% % Generate round
% labelmaps(max(y-radius, 1):min(y+radius, maph), ...
%   max(x-radius, 1):min(x+radius, mapw), c) = 1;
%
% [rr, cc] = meshgrid(1:mapw, 1:maph);
% labelmaps(:,:,c) = sqrt((rr-x).^2+(cc-y).^2)<=radius;

function [im, joints] = padding_pose(im, joints, normsize)
% pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];
[h, w, ~] = size(im);
if h > w
  diff = h - w;
  pad_left = randi(diff);
  pad_right = diff - pad_left;
  if pad_left == 0
    pad_im = subarray(im, 1, h, 1, w+diff,0);
  else  
    pad_im = subarray(im, 1, h, 1-pad_left, w+pad_right,0);
  end
  joints(:, 1) = joints(:, 1) + pad_left;
elseif w > h
  diff = w - h;
  pad_top = randi(diff);
  pad_bottom = diff - pad_top;
  if pad_top == 0
    pad_im = subarray(im, 1, h+diff, 1, w,0);
  else  
    pad_im = subarray(im, 1-pad_top, h+pad_bottom, 1, w, 0);
  end
  joints(:, 2) = joints(:, 2) + pad_top;
else
  pad_im = im;
end
% showskeletons_joints(pad_im, joints, pa); hold on; pause; close;
if max(h,w) < normsize % adding extra padding
  ext_pad = floor((normsize - max(h,w))/2);
  im = subarray(pad_im, 1-ext_pad, size(pad_im, 1)+ext_pad,...
    1-ext_pad, size(pad_im,2)+ext_pad, 0);
  joints(:, 1:2) = joints(:, 1:2) + ext_pad;
else % reduce to normsize
  scale = normsize/size(pad_im, 1);
  im = imresize(pad_im, scale);
  joints(:, 1:2) = joints(:, 1:2)*scale;
end
im = imresize(im, [normsize, normsize]);