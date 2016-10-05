function [Ix, Iy] = srm_imgGrad(I)
% This function outputs the x-derivative and y-derivative of the
% input I. If I is 3D, then derivatives of each channel are
% available in xd and yd.
Ix=zeros(size(I));
Iy=zeros(size(I));

sob=[-1,9,-45,0,45,-9,1]/60;
for i=1:size(I,3)
    Ix(:,:,i)=imfilter(I(:,:,i),sob,'replicate');
    Iy(:,:,i)=imfilter(I(:,:,i),sob','replicate');
end
