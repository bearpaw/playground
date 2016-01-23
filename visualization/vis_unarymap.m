
% ------------------------------------------------------------------------
function vis_unarymap(im, pyra, unary_map, pa, bbox)
% ------------------------------------------------------------------------

pyra_boxes = im_to_pyra_coords(pyra, bbox);

clf;

rows = 2;
cols = 4;
points = [bbox(:, 1)+bbox(:, 3), bbox(:, 2)+bbox(:, 4)]*0.5;

%--------------------------
% draw ground truth
subplot(rows, cols, 1);
msize = 4;
p_no = numel(pa);

switch p_no
  case 26
    partcolor = {'g','g','y','r','r','r','r','y','y','y','m','m','m','m','y','b','b','b','b','y','y','y','c','c','c','c'};
  case 14
    partcolor = {'g','g','y','r','r','y','m','m','y','b','b','y','c','c'};
  case 18
    partcolor = {'g','g','y','r','r','r','r','y','y','y','y','b','b','b','b','y','y','y'};
  otherwise
    error('showboxes: not supported');
end
imshow(im); hold on;
if ~isempty(points)
  x = points(:,1);
  y = points(:,2);
  for n = 1:size(x,1)
    for child = 2:p_no
      x1 = x(pa(child));
      y1 = y(pa(child));
      x2 = x(child);
      y2 = y(child);
      %             if (child == 2)
      plot(x1, y1, 'o', 'color', partcolor{child}, ...
        'MarkerSize',msize, 'MarkerFaceColor', partcolor{child});
      %             end
      plot(x2, y2, 'o', 'color', partcolor{child}, ...
        'MarkerSize',msize, 'MarkerFaceColor', partcolor{child});
      line([x1 x2],[y1 y2],'color',partcolor{child},'linewidth',round(msize/2));
    end
  end
end
drawnow; hold off;

%--------------------------------------
% draw feature map at level 1
max_val = 0;
min_val = 10e+10;
unary_map_hr = unary_map{1}; % unary_map with highest resolution
for level = 1:length(unary_map_hr)
  f = unary_map_hr{level};
  max_val = max(max_val, max(f(:)));
  min_val = min(min_val, min(f(:)));
end

ld = load('green_colormap');
colormap(ld.map); clear ld;

pyra_box = pyra_boxes{1};
for level = 1:min(length( unary_map_hr), rows*cols-1)
  subplot(rows, cols, level+1);
  imagesc(exp(unary_map_hr{level}));
  axis image;
  rectangle('Position', pyra_box(level, :), 'EdgeColor', 'r');
%   title(sprintf('level %d; scale = %.2fx', level, pyra.scales(level)));
% 
%   % project pyramid box back to image and display as red
%   im_bbox = pyra_to_im_coords(pyra, [pyra_boxes{level} level]);
%   subplot(rows, cols, 1);
%   rectangle('Position', bbox_to_xywh(im_bbox), 'EdgeColor', 'r');
%   %text(im_bbox(1), im_bbox(2), sprintf('%d', level));
end

% ------------------------------------------------------------------------
function pyra_boxes = im_to_pyra_coords(pyra, boxes)
% ------------------------------------------------------------------------
% boxes is N x 4 where each row is a box in the image specified
% by [x1 y1 x2 y2].
%
% Output is a cell array where cell i holds the pyramid boxes
% coming from the image box

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
%
% This file is part of the DeepPyramid code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------
pyra_boxes = cell(1, length(pyra));
boxes = boxes - 1;
for level = 1:length(pyra)
  level_boxes = bsxfun(@times, boxes, pyra(level).scale);
  level_boxes = level_boxes + 1;
  level_boxes(:, [1 3]) = level_boxes(:, [1 3]) + pyra(level).padx;
  level_boxes(:, [2 4]) = level_boxes(:, [2 4]) + pyra(level).pady;
  pyra_boxes{level} = level_boxes;
end


% ------------------------------------------------------------------------
function xywh = bbox_to_xywh(bbox)
% ------------------------------------------------------------------------
xywh = [bbox(1) bbox(2) bbox(3)-bbox(1)+1 bbox(4)-bbox(2)+1];


