function [ luminanceMap ] = makeLuminanceMap( image )
%Creates a luminance map from an image
%
% The input image is expected to be a 3d matrix of size rows*columns*3

luminanceMap =  image(:,:,1);
