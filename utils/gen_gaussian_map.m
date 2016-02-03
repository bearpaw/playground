function [gmap, gmask] = gen_gaussian_map(map_h, map_w, hsize, sigma, x, y, showmap)
% Generate 2D Gaussian map given the mapsize, kernel size, and the position
% of the kernel center
% 
% Input
% - map_w, map_h: width and height of the resulting map
% - hsize: size of the Gaussian kernel
% - sigma: variance of the Gaussian kernel
% - (x, y): position of the kernel center
%
% Wei Yang | July 08 2015
% -------------------------------------------------------------------------
if nargin < 1 
  % for demo use
  map_w = 250; % map width
  map_h = 200; % map height

  % Gaussian kernel params
  hsize = 31;
  sigma = 5;

  % kernel center position
  x = 200;
  y = 150;
  
  showmap = 1;
end

x = max(1, round(x));
y = max(1, round(y));
x = min(map_w, round(x));
y = min(map_h, round(y));


if x < 1 || y < 1 || x > map_w || y > map_h
  error('Error: (x, y) out of the map boundary.');
end

hsize = round(hsize/2)*2+1;
hhsize= floor(hsize/2);

% generate kernel
gkernel = fspecial('gaussian', hsize, sigma);

% normalize
gkernel = gkernel/max(gkernel(:));
% compute kernel start index and end index
ksx = 1;
ksy = 1;
kex = hsize;
key = hsize;

% compute map start index and end index
msx = x-hhsize;
msy = y-hhsize;
mex = x+hhsize;
mey = y+hhsize;

if y-hhsize < 1  
  ksy = 1-(y-hhsize)+1;
  msy = 1;
end

if x-hhsize < 1
  ksx = 1-(x-hhsize)+1;
  msx = 1;
end

if y+hhsize > map_h
  key = hsize - ((y+hhsize)-map_h);
  mey = map_h;
end

if x+hhsize > map_w
  kex = hsize - ((x+hhsize)-map_w);
  mex = map_w;
end
  
gmap = zeros(map_h, map_w);
gmask = zeros(map_h, map_w);

a= gkernel(ksy:key, ksx:kex);
b = gmap(msy:mey,  msx:mex);

gmap(msy:mey,  msx:mex) = gkernel(ksy:key, ksx:kex);
gmask(msy:mey,  msx:mex) = 1;

if showmap
  imagesc(gmap);
  colormap(gray);
end
