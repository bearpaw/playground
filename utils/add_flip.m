function imdata = add_flip(imdata, mirror)
% ---------- flip version --------
num = numel(imdata);
new_imdata = cell(num, 1);

parfor ii = 1:num
  c_imdata = imdata(ii);
  new_imdata{ii} = c_imdata;
  if isfield(c_imdata, 'r_degree')
    % never flip rotated images
    assert(c_imdata.r_degree == 0);
  end
  if isfield(c_imdata, 'joints') && ~isempty(c_imdata.joints)
    im = imreadx(c_imdata);
    width = size(im,2);
    new_imdata{ii}.joints(mirror, 1) = max(1, width - c_imdata.joints(:,1) + 1);
    new_imdata{ii}.joints(mirror, 2) = c_imdata.joints(:,2);
    new_imdata{ii}.joints(mirror, 3) = c_imdata.joints(:,3);  % fix bug: also mirror validility
    % also flip invalid (if exist)
    if isfield(c_imdata, 'invalid')
      new_imdata{ii}.invalid(mirror) = c_imdata.invalid;
    end
  end
  new_imdata{ii}.isflip = 1;
  
  if 0 % DEBUG
    flip_im = imreadx(new_imdata{ii});
    pa = [0 1 2 3 4 3 6 7 2 9 10 9 12 13];  % parent order (14 parts)
    showskeletons_joints(flip_im, new_imdata{ii}.joints, pa); hold on; pause; close;
  end
end

imdata = cat(1, imdata, new_imdata{:});
