% [A]= fast_sift_bin_similarity_matrix(YNBP, XNBP, NBO, threshold)
% 
% Computes the bin-similarity matrix between the bins of SIFT descriptor.
% Let two SIFT bins i and j, be (y_i,x_i,o_i) and (y_j,x_j,o_j)
% respectively. The similarity between them is:
%  a_ij= 1-d_ij/threshold
%  d_ij= min( ||(x_i-x_j,y_i-y_j)||_2 + min(|o_i-o_j|,NBO-|o_i-o_j|) , threshold )
% This similarity function was used together with the QC distance in the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010
% The SIFT descriptor was described in the paper:
%  Distinctive Image Features from Scale-Invariant Keypoints
%  David Lowe
%  IJCV 2004
%
% Output:
%  A - The sparse bin-similarity matrix. That is, A(i,j) is the
%  similarity between bin i and bin j of a SIFT descriptor. Where the
%  layout of the descriptor is: YNBP, XNBP, NBO (NBO runs fastest). This
%  is the layout that is used in Andrea Vedaldi's code for computing SIFT
%  descriptors which can be found here:
%  http://www.vlfeat.org/~vedaldi/assets/sift/binaries/
%  Note that his new library - "vlfeat" does not support changing the
%  number of spatial and orientation bins.
%
% Required Input:
%  YNBP, XNBP - Number of Y and X spatial SIFT cells (both are 4 in
%               original SIFT)
%  NBO - Number of SIFT orientation bins (8 in original SIFT, but 16 can
%        be better for cross-bin distances such as QC).
%  threshold - Above this threshold similarity is 0.
%
% Time Complexity:
%  min( (threshold^3),(YNBP+XNBP+NBO)^2 )


% Implementation in a mex file.


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