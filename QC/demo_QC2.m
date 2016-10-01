% This demo efficiently computes the QC histogram distance between two
% random SIFTs histograms (3d histograms, see Lowe's paper: "Distinctive
% image features from scale-invariant keypoints" for more detail) where 
% the bin-similarity matrix is sparse and inversely corresponds to a
% thresholded sum of orientation and spatial distance.
% The QC histogram distance is described in the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010

clc; close all; clear all;
rand('state',sum(100*clock));


if (exist('fast_sift_bin_similarity_matrix')~=3)
    error(['fast_sift_bin_similarity_matrix compiled function, does not exist. Please use ' ...
           'compile_QC in Matlab or make in a linux shell.']);
end

YNBP= 6; % SIFT's Y-dimension
XNBP= 8; % SIFT's X-dimension
NBO= 8; % SIFT's Orientation-dimension
thresh= 2; % distance threshold that above it similarity is 0
% The normalization factor. Should be 0 <= m < 1. 
% 0.9 experimentally yielded good results. 0.5 is the generalization of
% chi^2 which also yields good results.
m= 0.9;

% A is the sparse bin-similarity matrix.
tic
A= fast_sift_bin_similarity_matrix(YNBP, XNBP, NBO, thresh);
fprintf(1,'Computing the bin-similarity matrix took %f seconds\n', ...
        toc);
fprintf(1,['Note that the bin-similarity matrix can be computed once for ' ...
           'comparing many SIFT descriptors.\n\n']);

N= YNBP*XNBP*NBO;
P= rand(1,N);
Q= rand(1,N);

% The demo includes several ways to call QC
demo_QC_compute(P, Q, A, m);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computing with signatures.  The code is commented out as it is very
% slow. QC_signatures should be used only when the offline computation of
% the full bin-similarity matrix is not practical and it is not possible to
% compute it faster online (see demo_QC4 for an example of fast online
% computation of the partial bin-similarity matrix).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PF= zeros(3, N);
% QF= zeros(3, N);
% PW= P;
% QW= Q;
% i= 1;
% for y=1:YNBP
%     for x=1:XNBP
%         for o=1:NBO
%             PF(1,i)= y;
%             PF(2,i)= x;
%             PF(3,i)= o;
%             QF(1,i)= y;
%             QF(2,i)= x;
%             QF(3,i)= o;
%             i= i+1;
%         end
%     end
% end
% 
% % This is the Matlab way to bind parameters (NBO and thresh in this case)
% % to functions.
% F_sim= @(F1,F2)( sift_bin_similarity_function(F1, F2, NBO, thresh) );
% dist= QC_signatures(PF, QF, PW, QW, F_sim, m);
% assert( abs(dist-QC(P, Q, A, m))<0.00001 );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
