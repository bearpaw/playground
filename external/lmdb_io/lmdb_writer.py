import numpy as np
import lmdb
import caffe
import hashlib
import sys
import argparse
import scipy.io as sio
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
from os import path


if __name__ == '__main__':
    # create arguments
    parser = argparse.ArgumentParser('Convert images and .mat to LMDB.')
    parser.add_argument('rootfolder', type=str,
                        help='rootfolder of the files')
    parser.add_argument('data_file', type=str,
                        help='file of image list')
    parser.add_argument('label_file', type=str,
                        help='file of .mat list')
    parser.add_argument('data_db_name', type=str,
                        help='name of data LMDB')
    parser.add_argument('label_db_name', type=str,
                        help='name of label LMDB')
    parser.add_argument('var_name', type=str,
                        help='variable name for data in .mat')
    args = parser.parse_args()
    # create lmdb
    data_env = lmdb.open(args.data_db_name, map_size=int(1e12))
    label_env = lmdb.open(args.label_db_name, map_size=int(1e12))
    
    data_txn = data_env.begin(write=True)
    label_txn = label_env.begin(write=True)

    # open data/label list
    data_file = open(args.data_file)
    label_file = open(args.label_file)
    # read data/label lines
    data_lines = data_file.readlines()
    label_lines = label_file.readlines()
    # check the length of data and label file
    assert len(data_lines) == len(label_lines), 'length of data is not equal to length of label'
    nfiles = len(data_lines)
    for cnt in range(nfiles):
        # parsing file path
        data_path,  dummy_label = data_lines[cnt].split()
        label_path, dummy_label = label_lines[cnt].split()
        data_path = path.normpath(path.join(args.rootfolder, data_path)) # get abs path
        label_path = path.normpath(path.join(args.rootfolder, label_path)) # get abs path

        # read data
        data = np.asarray(mpimg.imread(data_path))    
        data = data[...,[2,1,0]]  # RGB -> BGR
        # data = np.rot90(data, 2)  # rotate
        data = np.transpose(data, (2, 1, 0))  # [dim, row, col] 

        # read label
        mat = sio.loadmat(label_path, variable_names=args.var_name)
        label = mat[args.var_name]
        label = np.transpose(label, (2, 1, 0))  # [dim, row, col]  
        # generate key string
        key = hashlib.md5(str(cnt).zfill(8)).hexdigest()
        # generate datum
        data_datum  = caffe.io.array_to_datum(data)
        label_datum = caffe.io.array_to_datum(label)
        # write to LMDB
        data_txn.put(key, data_datum.SerializeToString())
        label_txn.put(key, label_datum.SerializeToString())

        if cnt%10000 == 0:
            print 'Processing %d of %d data' % (cnt, nfiles)
            data_txn.commit()
            label_txn.commit()
            data_txn = data_env.begin(write=True)
            label_txn = label_env.begin(write=True)
        # # Two subplots, the axes array is 1-d
        # f, axarr = plt.subplots(2)
        # axarr[0].imshow(data[1,:,:])
        # axarr[1].imshow(label[1,:,:])
            # plt.show()
    data_env.close()
    label_env.close()



        


 
