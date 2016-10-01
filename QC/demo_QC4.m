% This demo loads two color images and efficiently computes a QC distance
% between them, where the the bin-similarity matrix is sparse and inversely
% corresponds to a a thresholded linear combination of the spatial and color
% distance between pixels, including pruning of spatially far pixels. This
% is the same distance which I used for color images in my ECCV paper. Image
% sizes need to be the same. As a color distance I used CIEDE2000.
% The QC histogram distance is described in the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010
% CIEDE2000 is described in the papers:
% The development of the CIE 2000 colour-difference formula: CIEDE2000
%  M. R. Luo, G. Cui, B. Rigg
%  CRA 2001
% The CIEDE2000 color-difference formula: Implementation notes, supplementary test data, and mathematical observations
%  Gaurav Sharma, Wencheng Wu, Edul N. Dalal
%  CRA 2004
clc; close all; clear all;

if (exist('fast_color_spatial_ground_similarity_pruning')~=3)
    error(['fast_color_spatial_ground_similarity_pruning compiled function, does not exist. Please use ' ...
           'compile_QC in Matlab or make in a linux shell.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Distance parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the paper I used threshold=20, but I didn't multiplied the color
% distance with alpha_color and the spatial distance with 1-alpha_color. So
% using threshold=10 is equivalent to what I used in the paper. That is, 
% threshold=T_1*alpha_color, for T_1 in eq 10 pg 9 in my ECCV 2010 paper.
threshold= 10;
alpha_color= 0.5;
% Pixels that are more than spatial_threshold far are considered totally
% different and their similarity is 0. This is T_2 in eq 10 pg 9 in my ECCV
% 2010 paper. This allows pruning in the computation of the bin-similarity
% matrix, which makes it run much faster: O(im1_N*spatial_threshold^2)
% instead of O(im1_N^2)
spatial_threshold= 5; 
im_resize_factor= 1/30;
% The normalization factor. Should be 0 <= m < 1. 0.5 experimentally
% yielded good results for color images. 0.5 is the generalization of
% chi^2. Running time can be improved for 0.5 by calling sqrt(x) instead of
% pow(x,0.5), but I did not implement it here yet.
m= 0.5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
im1= imresize( imread('1.jpg') , im_resize_factor);
im2= imresize( imread('2.jpg') , im_resize_factor);
% 3.jpg is more similar to 1.jpg.
%im2= imresize( imread('3.jpg') , im_resize_factor);
im1_Y= size(im1,1);
im1_X= size(im1,2);
im1_N= im1_Y*im1_X;
im2_Y= size(im2,1);
im2_X= size(im2,2);
im2_N= im2_Y*im2_X;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QC input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P= [ ones(1,im1_N)  ,  zeros(1,im2_N) ];
Q= [ zeros(1,im1_N) ,  ones(1,im2_N)  ];

im1= double(im1)./255;
im2= double(im2)./255;
cform = makecform('srgb2lab');
im1_lab= applycform(im1, cform);
im2_lab= applycform(im2, cform);
% Creating the sparse bin-similarity matrix.  Loops in Matlab are very slow,
% so I use mex.
tic
A= fast_color_spatial_ground_similarity_pruning(...
    im1_lab, im2_lab,...
    alpha_color, threshold, spatial_threshold);
fprintf(1,'Computing the bin-similarity matrix took %f seconds\n', ...
        toc);
fprintf(1,'Note that the bin-similarity matrix should be computed for each two new images.\n');
fprintf(1,'If this is too slow, one can quantize the space (color and spatial location) '); 
fprintf(1,'and pre-compute a matrix only once.\n\n');
% The demo includes several ways to call QC
demo_QC_compute(P, Q, A, m);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% Copyright (c) 2010, Ofir Pele
% All rights reserved.

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met: 
%    * Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
%    * Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
%    * Neither the name of the The Hebrew University of Jerusalem nor the
%    names of its contributors may be used to endorse or promote products
%    derived from this software without specific prior written permission.

% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
% CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
