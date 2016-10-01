function [] = demo_QC_compute(P, Q, A, m)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[] = demo_QC_compute(P, Q, A, m)
% Demo of QC computations 
% This part is common to several demo_QC scripts
% Input:
%  P,Q full histograms
%  A   sparse bin-similarity matrix
%  m   normalization factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
QC_EPSILON= 0.001;


if (exist('check_if_QC_valid_bin_similarity_matrix')~=3)
    error(['QC_full_sparse compiled function, does not exist. Please use ' ...
           'compile_QC in Matlab or make in a linux shell.']);
end


tic 
dist1= QC_full_sparse(P,Q,A,m);
fprintf('Computing QC_full_sparse (P,Q: full, A: sparse) took %f seconds.\n', ...
        toc);

tic 
dist2= QC(P,Q,A,m);
fprintf('Computing QC             (P,Q: full, A: sparse) took %f seconds.\n',toc);
assert(abs(dist2-dist1)<QC_EPSILON);
    
fA= full(A);
tic 
dist3= QC(P,Q,fA,m);
fprintf('Computing QC             (P,Q: full, A: full)   took %f seconds.\n',toc);
assert(abs(dist3-dist1)<QC_EPSILON);

fprintf('\nExplanations:\n');
fprintf(' 1. Calling QC_full_sparse directly is the fastest method as\n');
fprintf('    we avoid checks of input and call the mex file directly.\n');
fprintf(' 2. Calling QC with a full A (bin-simialrity matrix) is \n');
fprintf('    slowest because T (threshold) is small and it runs \n');
fprintf('    with time complexity of O(N^2) instead of O(NT).\n');


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
