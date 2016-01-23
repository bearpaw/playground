function h = show_multi_skeletons_joints(im, joints, pa, msize, partcolor, upS)
if nargin < 4
  msize = 4;
end
if nargin < 5
  partcolor = {'g','y','r','m','b', 'c'};
end
if nargin < 6
  upS = 1;
end

p_no = numel(pa);

im = imresize(im, upS);

h = figure;
imshow(im, 'Border','tight'); hold on;
nmethods = length(joints);
for mm = 1:nmethods
  points = joints{mm};
  if ~isempty(points)
    x = points(:,1)*upS;
    y = points(:,2)*upS;
    for n = 1:size(x,1)
      for child = 2:p_no
        x1 = x(pa(child));
        y1 = y(pa(child));
        x2 = x(child);
        y2 = y(child);
        line([x1 x2],[y1 y2],'color',partcolor{mm},'linewidth',round(msize/3));
        %             if (child == 2)
        plot(x1, y1, 'o', 'color', partcolor{mm}, ...
          'MarkerSize',msize, 'MarkerFaceColor', partcolor{mm}, ...
          'MarkerEdgeColor','k', 'linewidth', round(msize/3));
        %             end
        plot(x2, y2, 'o', 'color', partcolor{mm}, ...
          'MarkerSize',msize, 'MarkerFaceColor', partcolor{mm}, ...
          'MarkerEdgeColor','k', 'linewidth', round(msize/3));
      end
    end
  end
end
% drawnow; hold off;
