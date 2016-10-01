% This demo efficiently computes the QC histogram distance between two 1d
% histograms where the bin-similarity matrix is sparse and inversely corresponds to
% a thresholded L_1 distance between the bins.
% The QC histogram distance is described in the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010

clc; close all; clear all;
rand('state',sum(100*clock));

% The dimension of the histogram
N= 5000; 
% A pair of bins with L_1 distance greater or equal to
% THRESHOLD get a similarity of 0.
THRESHOLD= 3;
% The normalization factor. Should be 0 <= m < 1. 
% 0.9 experimentally yielded good results. 0.5 is the generalization of
% chi^2 which also yields good results.
m= 0.9;

% The two histograms
P= rand(1,N);
Q= rand(1,N);

% The sparse bin-similarity matrix. See other demos for fast mex
% computation of this kind of matrix.
A= sparse(N,N);
for i=1:N
    for j=max([1 i-THRESHOLD+1]):min([N i+THRESHOLD-1])
        A(i,j)= 1-(abs(i-j)/THRESHOLD); 
    end
end

% The demo includes several ways to call QC
demo_QC_compute(P, Q, A, m);





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
