function h = showskeletons(im, boxes, pa, msize)
if nargin < 4
  msize = 4;
end
p_no = numel(pa);

switch p_no
  case 26
      partcolor = {'g','g','y','m','m','m','m','y','y','y','r','r','r','r','y','c','c','c','c','y','y','y','b','b','b','b'};
%     partcolor = {'g','g','y','r','r','r','r','y','y','y','m','m','m','m','y','b','b','b','b','y','y','y','c','c','c','c'};
  case 14
    partcolor = {'g','g','y','r','r','y','m','m','y','b','b','y','c','c'};
  case 18
    partcolor = {'g','g','y','r','r','r','r','y','y','y','y','b','b','b','b','y','y','y'};
  otherwise
    error('showboxes: not supported');
end
% f = figure;
h = imshow(im); hold on;
if ~isempty(boxes)
  box = boxes(:,1:4*p_no);
  xy = reshape(box,size(box,1),4,p_no);
  xy = permute(xy,[1 3 2]);
  for n = 1:size(xy,1)
    x1 = xy(n,:,1); y1 = xy(n,:,2); x2 = xy(n,:,3); y2 = xy(n,:,4);
    x = (x1+x2)/2; y = (y1+y2)/2;
    for child = 2:p_no
      
      if pa(child) == 0 || child == 0
        continue;
      end
      
      x1 = x(pa(child));
      y1 = y(pa(child));
      x2 = x(child);
      y2 = y(child);
      
      line([x1 x2],[y1 y2],'color',partcolor{child},'linewidth',round(msize/2));
      plot(x1, y1, 'o', 'color', partcolor{child}, ...
        'MarkerSize',msize, 'MarkerFaceColor', partcolor{child});
      plot(x2, y2, 'o', 'color', partcolor{child}, ...
        'MarkerSize',msize, 'MarkerFaceColor', partcolor{child});
%       plot(x1, y1, 'o', 'color', partcolor{child}, ...
%         'MarkerSize',msize, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
%       plot(x2, y2, 'o', 'color', partcolor{child}, ...
%         'MarkerSize',msize, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');

    end
  end
end
drawnow; hold off;
