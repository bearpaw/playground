rm -rf cache/mpii-softgt/train_data_LMDB
rm -rf cache/mpii-softgt/val_data_LMDB

./external/caffe/build/tools/convert_imageset -backend lmdb /home/wyang/code/pose/fcn-pose-eccv16/ cache/mpii-softgt/train_data_lmdb.txt cache/mpii-softgt/train_data_LMDB
./external/caffe/build/tools/convert_imageset -backend lmdb /home/wyang/code/pose/fcn-pose-eccv16/ cache/mpii-softgt/val_data_lmdb.txt cache/mpii-softgt/val_data_LMDB