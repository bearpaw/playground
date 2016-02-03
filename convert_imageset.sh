rm -rf cache/mpii/train_data_LMDB
rm -rf cache/mpii/val_data_LMDB

./external/caffe/build/tools/convert_imageset -backend lmdb /home/wyang/code/pose/fcn-pose-eccv16/ cache/mpii/train_data_lmdb.txt cache/mpii/train_data_LMDB
./external/caffe/build/tools/convert_imageset -backend lmdb /home/wyang/code/pose/fcn-pose-eccv16/ cache/mpii/val_data_lmdb.txt cache/mpii/val_data_LMDB