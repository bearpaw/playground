function imdata = add_rotate(imdata, degree)
if isempty(degree)
  return;
end
num = numel(imdata);
n_degree = numel(degree);
new_imdata = cell(num, 1);
% ---------- roated images --------
parfor ii = 1:num
  im = imreadx(imdata(ii));
  c_imdata = imdata(ii);
  new_imdata{ii} = repmat(c_imdata, [n_degree, 1]);
  for dd = 1:numel(degree)
    new_imdata{ii}(dd).joints = map_rotate_points(c_imdata.joints,im,degree(dd),'ori2new');
    new_imdata{ii}(dd).r_degree = degree(dd);
    if 0 % DEBUG
      rotate_im = imreadx(new_imdata{ii}(dd));
      pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];  % parent order (14 parts)
      showskeletons_joints(rotate_im, new_imdata{ii}(dd).joints, pa); hold on; pause; close;
    end
  end
end

imdata = cat(1, imdata, new_imdata{:});
