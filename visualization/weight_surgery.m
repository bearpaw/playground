startup;
clear mex;
global GLOBAL_OVERRIDER;
% GLOBAL_OVERRIDER = @lsp_conf_official;
GLOBAL_OVERRIDER = @lsp_window_data_conf;
conf = global_conf();

cachedir = conf.cachedir;
pa = conf.pa;
p_no = length(pa);
note = [conf.note];
diary([cachedir note '_log_' datestr(now,'mm-dd-yy') '.txt']);
isvisualize = false;

cnnpar = conf.cnn;
caffe.reset_all();
if ~exist(cnnpar.cnn_deploy_conv_file, 'file') || ~exist(cnnpar.cnn_conv_model_file, 'file')
  error('model files not exist');
end
caffe.set_mode_gpu();
caffe.set_device(conf.device_id);

net = caffe.Net(cnnpar.cnn_deploy_conv_file, ...
  cnnpar.cnn_conv_model_file, 'test'); % create net and load weights

conv1w = net.params('conv1',1).get_data();
display_network_4D(conv1w, 'conv');
f=getframe(gca);
% imwrite(imresize(f.cdata, 5, 'nearest'),sprintf('~/weight_%s_official.png', 'conv1'));
imwrite(imresize(f.cdata, 5, 'nearest'),sprintf('~/weight_%s.png', 'conv1'));