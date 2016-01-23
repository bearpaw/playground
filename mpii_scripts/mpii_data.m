close all;
DEBUG = 1;
% -------- configurations --------
conf.dataset = '/home/wyang/Data/dataset/mpii_human_pose';  % dataset path
conf.note = 'mpii';
conf.order = [10, 9, 13, 12, 11, 3, 2, 1, 14, 15, 16, 4, 5, 6]; % re-order
conf.pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];  % parent order (14 parts)
conf.cachedir = './cache/mpii';

if ~exist(conf.cachedir, 'dir')
  mkdir(conf.cachedir);
end

cls = [conf.note, num2str(numel(conf.pa)), '_data'];
try
  load([cachedir cls]);
catch
  % -------- separate train/test set --------
  if ~exist('RELEASE', 'var')
    load([ conf.dataset  '/mpii_human_pose_v1_u12_1/mpii_human_pose_v1_u12_1.mat']);
  end
  
  single_num = sum(cellfun(@numel,RELEASE.single_person));
  single_idx = find(~cellfun(@isempty,RELEASE.single_person));
  trainval_frs_pos = intersect(find(RELEASE.img_train==1), single_idx);  % training frames for positive
  test_frs_pos = find(RELEASE.img_train==0);  % testing frames for positive
  
  assert( isempty( intersect(trainval_frs_pos, test_frs_pos)))
  
  all_pos = struct('im', cell(single_num, 1), 'joints', cell(single_num, 1), ...
    'r_degree', cell(single_num, 1), 'isflip', cell(single_num,1));
  aptr = 1;
  % -------- create reformatted train data --------
  for i = 1:length(trainval_frs_pos)
    iminfo = RELEASE.annolist(trainval_frs_pos(i));
    single_persons = RELEASE.single_person{trainval_frs_pos(i)};
    im = imread([conf.dataset '/images/' iminfo.image.name]);
    % ---------------------------------
    % We crop each person and resize the image according to its scale
    % to obtain 300px body height
    for spid = 1:length(single_persons)
      anno = single_persons(spid);
      head_bbx = [iminfo.annorect(anno).x1 iminfo.annorect(anno).y1 ...
        iminfo.annorect(anno).x2 iminfo.annorect(anno).y2];
      joints = zeros(16, 3)-1;
      for id = 1:length([iminfo.annorect(anno).annopoints.point.id])
        point = iminfo.annorect(anno).annopoints.point(id);
        pid = point.id+1;
        joints(pid, 1) = point.x;
        joints(pid, 2) = point.y;
        if ~isempty(point.is_visible)
          if ischar(point.is_visible)
            joints(pid, 3) = str2num( point.is_visible);
          else
            joints(pid, 3) = point.is_visible;
          end
        else
          joints(pid, 3) = 1;
        end
      end
      % reorder joints (skip interpolated joints)
      joints = joints(conf.order, :);
      
      % rescale images
      scale = 1/(iminfo.annorect(anno).scale*200/340);
      
      % save to all_pos
      all_pos(aptr).im = iminfo.image.name;
      all_pos(aptr).scale = iminfo.image.name;
      all_pos(aptr).joints = joints;
      all_pos(aptr).r_degree = 0;
      all_pos(aptr).isflip = 0;
      
      if DEBUG
        scaled_im = imresize(im, scale);
        scaled_joints = joints;
        scaled_joints(:, 1:2) = joints(:, 1:2) * scale;
        
        head_length = norm(joints(1, 1:2) - joints(2, 1:2));
        thead_length = norm(scaled_joints(1, 1:2) - scaled_joints(2, 1:2));
        
        fprintf('height: %.2f | norm height: %.2f\n', head_length, thead_length);
        imshow(scaled_im); hold on;
        showskeletons_joints(scaled_im, scaled_joints, conf.pa); hold on;
        pause; close;
      end
    end
  end
end
