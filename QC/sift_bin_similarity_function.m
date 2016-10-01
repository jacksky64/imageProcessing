function [sim]= sift_bin_similarity_function(F1, F2, NBO, threshold)
% [sim]= sift_bin_similarity_function(F1, F2, NBO, threshold)
% Computes the bin-similarity between two bins of SIFT descriptor.  It is
% used in the demonstration of the QC_signatures interface which is in
% demo_QC2 at the bottom commented out as it is much more efficient to use
% fast_sift_bin_similarity_matrix and QC_full_sparse. The code here is
% provided to show the usage of QC_signatures.
% 
% Output:
%  sim - the similarity between two sift bins
%
% Input:
%  F1,F2 - Two SIFT bins (3D vectors: y, x, orientation).
%  NBO - Number of SIFT orientation bins (8 in original SIFT, but 16 can
%        be better for cross-bin distances such as QC).
%  threshold - Above this threshold similarity is 0.
d_y= F1(1)-F2(1);
d_x= F1(2)-F2(2);
d_spatial= sqrt( d_x*d_x + d_y*d_y );

d_abs_o= abs(F1(3)-F2(3));
d_o= min([ d_abs_o NBO-d_abs_o ]);

d= d_spatial+d_o;

d= min([d threshold]);

sim= 1 - d/threshold;



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
