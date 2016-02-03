function conf = mpii_conf
conf.dataset = '/home/wyang/Data/dataset/mpii_human_pose';  % dataset path
conf.note = 'mpii-softgt';  % database name for cache
conf.order = [10, 9, 13, 12, 11, 3, 2, 1, 14, 15, 16, 4, 5, 6];  % re-order
conf.mirror = [1, 2, 9, 10, 11, 12, 13, 14, 3, 4, 5, 6, 7, 8];
conf.pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];  % parent order (14 parts)
conf.cachedir = ['cache/' conf.note '/'];  
conf.radius = 56;  % radius of groundtruth joint mask 
conf.sigma = 2;
conf.norm_height = 448;  % normalize body height
% conf.crop_scale = 24;
conf.context = 56;
conf.stride = 8;

d_step = 5;
conf.degree = [-35:d_step:-d_step,d_step:d_step:35];

if ~exist(conf.cachedir, 'dir')
  mkdir(conf.cachedir);
end

%  --- Caffe model file 
conf.cnn.cnn_deploy_file = './external/my_models/mpii/mpii_deploy.prototxt';
conf.cnn.cnn_model_file = './cache/mpii-softgt/caffemodels-labeldropout/mpii_vgg16_large_fov_iter_500.caffemodel';
conf.cnn.gpu_id = 1;
conf.cnn.mean_pixel = [104.008, 116.669, 122.675];