% A= fast_color_spatial_ground_similarity_pruning(im1_lab, im2_lab, alpha_color, threshold, spatial_threshold)
%
% Computes the bin-similarity matrix between im1_lab and im2_lab (ims should
% be in L*a*b* space). This is the bin-similarity computation used in the
% paper:
%  The Quadratic-Chi Histogram Distance Family
%  Ofir Pele, Michael Werman
%  ECCV 2010
% The similarity between the pixels (x1,y1,L1,a1,b1) and (x2,y2,L2,a2,b2) is
% (see also eq 10 pg 9 in my ECCV paper):
%  1-min(alpha_color*CIEDE2000(L1,a1,b1,L2,a2,b2) +   if ||(x1-x2,y1-y2)||_2 <= spatial_threshold
%        (1-alpha_color)*||(x1-x2,y1-y2)||_2          
%        , threshold) / threshold                      
%  0                                                  otherwise
%
% Output:
%  A - the sparse bin-similarity matrix. A size is: (im1_N+im2_N)^2,
%      where: im#_N size(im#_lab,1)*size(im#_lab,2) (note that we assume
%      im1_N==im2_N).
%      Top-left sub-matrix is im1_lab pixels similarity to im1_lab pixels.
%      Top-right and bottom-left sub-matrices are im1_lab pixels similarity
%      to im2_lab pixels.  
%      Bottom-right sub-matrix is im2_lab pixels similarity to im2_lab pixels.
% 
% Input:
%  im1_lab, im2_lab: Two L*a*b* images of the same size.
%  alpha_color: weight of color distance in the similarity function (see above).
%  threshold: If distance is above it similarity is zero (see above).
%  spatial_threshold: If spatial distance is above it similarity is zero
%                     (see above).  Note that the function will run faster
%                     as spatial_threshold is smaller.
%
% Note: alpha_color*threshold should be smaller or equal to 20, as
% CIEDE2000 (like all other color distances) should be saturated. See:
%  Fast and Robust Earth Mover's Distances
%  Ofir Pele, Michael Werman
%  ICCV 2009
%
% Example of usage: see demo_QC4


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
