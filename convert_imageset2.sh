# rm -rf cache/mpii-softgt/val_data_LMDB
# rm -rf cache/mpii-softgt/val_label_LMDB

# python ./external/lmdb_io/lmdb_writer.py . \
# 	cache/mpii-softgt/val_data_lmdb.txt \
# 	cache/mpii-softgt/val_label_lmdb.txt \
# 	cache/mpii-softgt/val_data_LMDB \
# 	cache/mpii-softgt/val_label_LMDB \
# 	labelmaps


# rm -rf cache/mpii-softgt/train_data_LMDB
# rm -rf cache/mpii-softgt/train_label_LMDB


python ./external/lmdb_io/lmdb_writer.py . \
	cache/mpii-softgt/train_data_lmdb.txt \
	cache/mpii-softgt/train_label_lmdb.txt \
	cache/mpii-softgt/train_data_rotate_LMDB \
	cache/mpii-softgt/train_label_rotate_LMDB \
	labelmaps
