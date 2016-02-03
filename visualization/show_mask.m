function show_mask(im, mask, opacity)
[imh, imw, imc] = size(im);
[maskh, maskw, maskc] = size(mask);

assert(imh == maskh, 'Hight miss match!');
assert(imw == maskw, 'Weight miss match!');
assert(opacity >= 0 && opacity <= 1, 'Opacity should be in range [0, 1].');

for c = 1:maskc
  curmask = mask(:,:,c);
  minv = min(curmask(:)); maxv = max(curmask(:));
  curmask = uint8(((curmask - minv)/double(maxv))*255);
  curmask = repmat(curmask, 1, 1, imc);
  vim = uint8(im*opacity + curmask*(1-opacity));
  imshow(vim); pause; 
  close;
end
end