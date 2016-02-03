function test_model(conf, test)

caffe.reset_all();
caffe.set_mode_gpu();
caffe.set_device(conf.cnn.gpu_id );

net = caffe.Net(conf.cnn.cnn_deploy_file, ...
  conf.cnn.cnn_model_file, 'test'); % create net and load weights

for i = 1:length(test)
  joints = detect_pose(conf, test(i), net);
end