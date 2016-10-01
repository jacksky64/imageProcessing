% [dist]= QC_signatures(PF, QF, PW, QW, F_sim, m)
% 
% Computes the Quadratic-Chi (QC) histogram distance between two
% signatures (a convenient representation for sparse histograms).
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
% Required Input:
%  PF - DxN matrix, where each column is a D-dimensional feature vector
%       of the first signature.
%  QF - DxM matrix, where each column is a D-dimensional feature vector.
%       of the second signature.
%  PW - 1xN or Nx1, weights of first signature.
%  QW - 1xM or Mx1, weights of second signature.
%  F_sim - a function (handle) that gets as an input two D-dimensional
%          feature vectors and returns the similarity between them. 
%  m - The normalization factor (large m correspond to a large reduction of large bins effect).
%      In paper used 0.5 (QCS) or 0.9 (QCN).
%      Pre-condition: 0 <= m < 1, otherwise not continuous. 
%
%
% Time Complexity:
%  O((N+M)^2) * O(F_sim)
%
% Examples of usage:
%  See commented bottom of demo_QC2 and demo_QC3
function [dist]= QC_signatures(PF, QF, PW, QW, F_sim, m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sizes and asserts
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
D= size(PF,1);
N= size(PF,2);
assert(size(QF,1)==D);
M= size(QF,2);
assert(length(PW)==N);
assert(length(QW)==M);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P & Q
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (size(PW,1)==1)
    P= [PW,  zeros(1,M)];
else
    P= [PW', zeros(1,M)];
end
if (size(QW,1)==1)
    Q= [zeros(1,N), QW];
else
    P= [zeros(1,N), QW'];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
len= length(P);
A= zeros(len, len);
for i=1:N
    for j=1:N
        A(i,j)= F_sim(PF(:,i),PF(:,j));
    end
end
for i=1:N
    for j=1:M
        d= F_sim(PF(:,i),QF(:,j));
        A(i,j+N)= d;
        A(j+N,i)= d;
    end
end
for i=1:M
    for j=1:M
        A(i+N,j+N)= F_sim(QF(:,i),QF(:,j));
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dist= QC_full_full(P, Q, A, m);
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
