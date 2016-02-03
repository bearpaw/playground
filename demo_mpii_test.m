conf = mpii_conf();
%  --- generate mpii trainval data
[pos_train, pos_val] = mpii_data();

%  --- generate LMDB dataset
% prepare_caffe_data(conf, pos_train, pos_val);
% 
% %  --- train DCNN
% 
%  --- testing DCNN
test_model(conf, pos_train);