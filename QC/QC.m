function [dist]= QC(P, Q, A, m);
%[dist]= QC(P, Q, A, m)
% 
% Computes the Quadratic-Chi (QC) histogram distance between two histograms.
% QC distances are Quadratic-Form distances with a cross-bin
% chi-squared-like normalization. This normalization reduces the effect of
% large bins having undue influence. The Quadratic-Form part of QC takes care
% of cross-bin relationships (e.g. red and orange).  
%
% For more details on this distance see the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010
% Please cite the paper if you use this code.
%
% Output:
%  dist - the computed distance.
%
% Input:
%  P,Q - Two histograms of size N 
%        Pre-condition: should be >=0.
%  A - The NxN bin-similarity matrix.
%      Pre-condition 1: should be >=0
%      Pre-condition 2: for all i,j A(i,i)>=A(i,j) (an element is most similar to itself).
%  m - The normalization factor (large m correspond to a large reduction of large bins effect).
%      In paper used 0.5 (QCS) or 0.9 (QCN).
%      Pre-condition: 0 <= m < 1, otherwise not continuous. 
%
% Time Complexity:
%  P,Q full    |  A full:   O(N^2)
%  P,Q full    |  A sparse: O(sum(A~=0))
%  P,Q sparse  |  A full:   NOT SUPPORTED YET, but we can get the
%                           following time complexity. Let S=
%                           (sum(P~=0)+sum(Q~=0)) => O(SN)
%  P,Q sparse  |  A sparse: SUPPORTED ONLY IN C++ CURRENTLY (QC_sparse_sparse.hpp)
%                           Let S= (sum(P~=0)+sum(Q~=0)) and 
%                           Let K= an average of non-zeros entries in each
%                           row of the similarity matrix (in respect to where
%                           P and Q are different from 0) => O(SK)
%                           Note 1: This method uses O(N) memory (but time
%                           does not depend on N).
% Note: you can also call QC_full_full and QC_full_sparse, (corresponding
%  to the first two options above). No checks will be done in this case, so
%  it will run faster.
%
% Examples of usage:
%  See demo_QC1, demo_QC2 and demo_QC4


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ( ((issparse(P))&&(~issparse(Q))) || ((~issparse(P))&&(issparse(Q))) )
    error('P and Q should both be of the same type: sparse or full');
end
if (size(P,1)>1&&size(P,2)>1) 
    error('P should be a vector');
end
if (size(Q,1)>1&&size(Q,2)>1) 
    error('Q should be a vector');
end
N= length(P);
if (length(Q)~=N)
    error('P and Q should be both the same size');
end
if (size(A,1)~=N||size(A,2)~=N)
    error('A should be NxN matrix');
end
if ((m<0)||(m>=1)) 
    error(['m is not valid, should be 0 <= m < 1 (otherwise QC is not ' ...
           'continuos']);
end
if (~(all(P>=0)))
    error('All entries of P should be >=0');
end
if (~(all(Q>=0)))
    error('All entries of Q should be >=0');
end
% TODO - if I will support sparse_full or sparse_sparse directly in Matlab,
% this checks time complexity is higher than the QC computation.
% Possible solutions: 1. don't do this check if sparse_full or sparse_sparse, maybe add
%                        a flag that forces this check anyhow.
%                     2. Implement checks that are efficient for this case.
if (exist('check_if_QC_valid_bin_similarity_matrix')==3)
    check_if_QC_valid_bin_similarity_matrix(A);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4 different cases
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (~issparse(P))
    if (~issparse(A))
        dist= QC_full_full(P, Q, A, m);
    else
        dist= QC_full_sparse(P, Q, A, m);
    end
else
    if (~issparse(A))
        mexErrMsgTxt(['Not supported yet.  ' ...
                      'You can call QC_full_full(full(P),full(Q),A,m) instead.']);
    else
        mexErrMsgTxt(['Not supported in Matlab yet.  ' ...
                      'You can use the C++ version in QC_sparse_sparse directory, ' ...
                      'or call QC_full_full(full(P),full(Q),A,m) instead.']);
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





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
