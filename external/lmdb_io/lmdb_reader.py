import caffe
import lmdb
import math
import argparse
import numpy as np
import matplotlib.pyplot as plt
from scipy.misc import imresize
from caffe.proto import caffe_pb2
from PIL import Image
# Wei Yang 2015-08-19
# Source
#   Read LevelDB/LMDB
#   ==================
#       http://research.beenfrog.com/code/2015/03/28/read-leveldb-lmdb-for-caffe-with-python.html
#   Plot image
#   ==================
#       http://www.pyimagesearch.com/2014/11/03/display-matplotlib-rgb-image/
#   Creating LMDB in python
#   ==================
#       http://deepdish.io/2015/04/28/creating-lmdb-in-python/
if __name__ == '__main__':
    # create arguments
    parser = argparse.ArgumentParser('Read LMDB')
    parser.add_argument('data_lmdb_file', type=str,
                        help='path of data LMDB')
    parser.add_argument('label_lmdb_file', type=str,
                        help='path of label LMDB')
    args = parser.parse_args()
    # open LMDB    
    data_env = lmdb.open(args.data_lmdb_file)
    label_env = lmdb.open(args.label_lmdb_file)
    data_txn = data_env.begin()
    label_txn = label_env.begin()
    # get LMDB cursor
    data_cursor = data_txn.cursor()
    label_cursor = label_txn.cursor()
    # print statistics
    data_lmdb_stat = data_env.stat()
    label_lmdb_stat = label_env.stat()

    print '\n--- DATA LMDB INFO ---\n'
    print 'stat info: ', data_lmdb_stat
    print 'total num: ', data_lmdb_stat['entries']
    print '\n--- LABEL LMDB INFO ---\n'
    print 'stat info: ', label_lmdb_stat
    print 'total num: ', label_lmdb_stat['entries']
    # create Caffe datum
    data_datum = caffe_pb2.Datum()
    label_datum = caffe_pb2.Datum()
    for data, label in zip(data_cursor, label_cursor):
        data_key = data[0]
        data_val = data[1]
        label_key = label[0]
        label_val = label[1]
        # parse to caffe datum
        data_datum.ParseFromString(data_val)
        label_datum.ParseFromString(label_val)
        # convert datum to array
        data_array = np.transpose(caffe.io.datum_to_array(data_datum), (2, 1, 0))
        label_array = np.transpose(caffe.io.datum_to_array(label_datum), (2, 1, 0))*255
        # for display
        im = data_array[...,[2,1,0]]  # BGR -> RGB
        label_array = label_array.astype(np.uint8)
        
        nc = label_array.shape[2];
        for c in range(label_array.shape[2]):  
            f, axarr = plt.subplots(2)
            axarr[0].imshow(im)
            axarr[1].imshow(label_array[:,:,c])
            plt.show()
        

