function prepare_caffe_data(conf, pos_train, pos_val)
close all;
DEBUG = 0;
%%  --- create images / mat folders
if ~exist([conf.cachedir 'train_image'], 'dir')
  mkdir([conf.cachedir 'train_image']);
end
if ~exist([conf.cachedir 'val_image'], 'dir')
  mkdir([conf.cachedir 'val_image']);
end
if ~exist([conf.cachedir 'train_label'], 'dir')
  mkdir([conf.cachedir 'train_label']);
end
if ~exist([conf.cachedir 'val_label'], 'dir')
  mkdir([conf.cachedir 'val_label']);
end
%%  --- prepare TRAIN images/labels
disp('prepare TRAIN images/labels...');
if ~exist([conf.cachedir 'train_data_lmdb.txt'], 'file')
  
  %   mkdir([conf.cachedir 'train_image']);
  %   mkdir([conf.cachedir 'train_label']);
  %   selectidx = randperm(length(pos_train));
  %   pos_train = pos_train(selectidx);
  %   pos_train = pos_train(1:100);
  
  namelist = cell(length(pos_train), 1);
  
  parfor i = 1:length(pos_train)
    fprintf('%d | %d\n', i, length(pos_train));
    [~, name, ~] = fileparts(pos_train(i).im);
    if ~exist([conf.cachedir 'train_image/' name '.jpg'], 'file')
      name = sprintf('%s_flip_%d_rotate_%d', name, pos_train(i).isflip, pos_train(i).r_degree);
      [im, labelmaps] = gen_groundtruth(conf, pos_train(i), 1);
      assert(size(labelmaps,1)==56 && size(labelmaps,2)==56);
      imwrite(im, [conf.cachedir 'train_image/' name '.jpg']);
      parsave([conf.cachedir 'train_label/' name '.mat'], 'labelmaps');
    end
    namelist{i} = name;
  end
  % convert to lmdb
  write_text(conf, namelist, 'train_image', 'train_label', 'train', 1);
end

%%  --- prepare VAL images/labels
disp('prepare VAL images/labels...');
if ~exist([conf.cachedir 'val_data_lmdb.txt'], 'file')
  namelist = cell(length(pos_val), 1);
  parfor i = 1:length(pos_val)
    fprintf('%d | %d\n', i, length(pos_val));
    [~, name, ~] = fileparts(pos_val(i).im);
    name = sprintf('%s_flip_%d_rotate_%d', name, pos_val(i).isflip, pos_val(i).r_degree);
    if ~exist([conf.cachedir 'val_image/' name '.jpg'], 'file')
      [im, labelmaps] = gen_groundtruth(conf, pos_val(i), 1);
      imwrite(im, [conf.cachedir 'val_image/' name '.jpg']);
      parsave([conf.cachedir 'val_label/' name '.mat'], 'labelmaps');
    end
    namelist{i} = name;
  end
  % convert to lmdb
  write_text(conf, namelist, 'val_image', 'val_label', 'val', 1);
end


%% ------- Save Mat file to LMDB ---------
% convert Training LABEL to lmdb
% system(['python ./external/lmdb_io/lmdb_mat_writer.py . ' ...
%   conf.cachedir 'train_label_lmdb.txt ' ...
%   conf.cachedir 'train_label_LMDB labelmaps']);

% % convert Validation LABEL to lmdb
% system(['python ./external/lmdb_io/lmdb_mat_writer.py . ' ...
%   conf.cachedir 'val_label_lmdb.txt ' ...
%   conf.cachedir 'val_label_LMDB labelmaps']);
%
% system('./convert_imageset.sh');

function write_text(conf, namelist, imagedir, matdir, outname, shuffle)
idx = (1:length(namelist));
if shuffle
  idx = randperm(length(namelist));
end

datafile = fopen([conf.cachedir outname '_data_lmdb.txt'], 'w');
labelfile = fopen([conf.cachedir outname '_label_lmdb.txt'], 'w');
for i = 1:length(idx)
  % print data item
  fprintf(datafile, '%s %d\n', ...
    [conf.cachedir imagedir '/' namelist{idx(i)} '.jpg'], 0);
  % print label item
  fprintf(labelfile, '%s %d\n', ...
    [conf.cachedir matdir '/' namelist{idx(i)} '.mat'], 0);
end
