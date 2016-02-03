function [pos_train, pos_val] = mpii_data
close all;
DEBUG = 0;
% -------- configurations --------
conf = mpii_conf();

cls = [conf.note, num2str(numel(conf.pa)), '_data'];
try
%   NO_FOUND
  load([conf.cachedir cls]);
catch
  if ~exist('RELEASE', 'var')
    load([ conf.dataset  '/mpii_human_pose_v1_u12_1/mpii_human_pose_v1_u12_1.mat']);
  end
  % -------- separate train/val set --------
  val_index = parload([conf.dataset '/tompson/mpii_valid_pred/data/detections.mat'], 'RELEASE_img_index');
  train_index = setdiff((1:length(RELEASE.annolist)), val_index);
  % split train / test set
  single_idx = find(~cellfun(@isempty,RELEASE.single_person));
  trainval_frs_pos = intersect(find(RELEASE.img_train==1), single_idx);  % training frames for positive
  test_frs_pos = find(RELEASE.img_train==0);  % testing frames for positive
  % compute training instance number
  trainval_single_num = sum(cellfun(@numel,RELEASE.single_person(trainval_frs_pos)));
  assert( isempty( intersect(trainval_frs_pos, test_frs_pos)), ...
    'trainval / test set should have no overlap.');
  
  % -------- create pos_trainval --------
  pos_trainval = struct('im', cell(trainval_single_num, 1), 'joints', cell(trainval_single_num, 1), ...
    'r_degree', cell(trainval_single_num, 1), 'isflip', cell(trainval_single_num,1));
  bbox_length = zeros(trainval_single_num, 2);
  aptr = 1;
  for i = 1:length(trainval_frs_pos)
    iminfo = RELEASE.annolist(trainval_frs_pos(i));
    single_persons = RELEASE.single_person{trainval_frs_pos(i)};
    fprintf('%.6d | %.6d\n', i, length(trainval_frs_pos));
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
        if isfield(point, 'is_visible') && ~isempty(point.is_visible)
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
      
      % rescale images to 512 image patches
      scale = 1/(iminfo.annorect(anno).scale*200/conf.norm_height);
      %       scale = 1/(iminfo.annorect(anno).scale);
      
      % save to all_pos
      pos_trainval(aptr).im = [conf.dataset '/images/' iminfo.image.name];
      pos_trainval(aptr).scale = scale;
      pos_trainval(aptr).joints = joints;
      pos_trainval(aptr).r_degree = 0;
      pos_trainval(aptr).isflip = 0;
      
      % compute
      % delete invalid joints and crop image
      valid_joints = joints;
      valid_joints(find(joints(:,3)==-1), :) = [];
      
      min_joints = round(min(valid_joints, [], 1));
      max_joints = round(max(valid_joints, [], 1));
      
      bbox_length(aptr,:) = max_joints(1:2) - min_joints(1:2);
      
      %       labelmaps = gen_groundtruth(pos_trainval(aptr), conf.sigma, conf.padlen, conf.crop_scale);
      
      aptr = aptr + 1;
      if DEBUG
        %         im = imread([conf.dataset '/images/' iminfo.image.name]);
        %         scaled_im = imresize(im, scale);
        scaled_joints = joints;
        scaled_joints(:, 1:2) = joints(:, 1:2) * scale;
        
        maxlen(aptr-1) = max(scaled_joints(:));
        
        %         if maxlen(aptr-1) > 1000
        %           labelmaps = gen_groundtruth(pos_trainval(aptr-1), conf.sigma, conf.padlen, conf.crop_scale);
        %         end
        
        head_length = norm(joints(1, 1:2) - joints(2, 1:2));
        thead_length = norm(scaled_joints(1, 1:2) - scaled_joints(2, 1:2));
        
        [im, labelmaps] = gen_groundtruth(pos_trainval(aptr-1), conf.radius, conf.context);
        show_mask(im, labelmaps, 0.5);
        %         fprintf('height: %.2f | norm height: %.2f\n', head_length, thead_length);
        %         imshow(scaled_im); hold on;
        %         showskeletons_joints(scaled_im, scaled_joints, conf.pa); hold on;
        %         pause; close;
      end
    end
  end
  % -------- split train / val --------
  [~, it, ~] = intersect(trainval_frs_pos, train_index);
  [~, iv, ~] = intersect(trainval_frs_pos, val_index);
  assert( isempty( intersect(it, iv)), ...
    'train / val set should have no overlap.');
  pos_train = pos_trainval(it);
  pos_val = pos_trainval(iv);
  % -------- add flip to train set --------
  fprintf('flip training data\n');
  pos_train = add_flip(pos_train, conf.mirror);
  % --------- rotate trainval images ---------
  fprintf('rotate training data\n');
  degree = conf.degree;
  assert(numel(unique(degree)) == numel(degree));
  pos_train = add_rotate(pos_train, degree);
  save([conf.cachedir cls], 'pos_train', 'pos_val');
end

