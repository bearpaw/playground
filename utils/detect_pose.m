function joints = detect_pose(conf, iminfo, net)
mean_pixel(1,1,:) = single(conf.cnn.mean_pixel);
% im_data = imresize( caffe.io.load_image(iminfo.im), iminfo.scale );

im_data = imresize(imread(iminfo.im), iminfo.scale ); % read image
im_data = single(im_data(:, :, [3, 2, 1])); % convert from RGB to BGR
% minus mean
im_data = bsxfun(@minus, im_data, mean_pixel);

net.blobs('data').reshape([size(im_data) 1]);
net.reshape();
net.forward({im_data});      % softmax apply in caffe model.

prob1 = net.blobs('fc8').get_data();

for ii = 1:14
  clf;
  axis equal
  predmap = prob1(:,:,ii);
  fprintf('max: %.2f, mean: %.2f\n', max(predmap(:)), mean(predmap(:)));
  ax1 = subplot(1,2,1); imshow(imread(iminfo.im));
  ax2 = subplot(1,2,2); imagesc(predmap);
  pause;
end

prob = imresize(prob1, [size(im_data,1), size(im_data, 2)]);

% show_mask(uint8(bsxfun(@plus, im_data, mean_pixel)), prob, 0.5);
joints = [];