% This demo efficiently computes the QC histogram distance between two
% random D-dimensional histograms where the bin-similarity matrix is sparse
% and inversely corresponds to thresholded Euclidean (L_2) distance. 
% This is a demo of the usage of QC_signatures.
% The QC histogram distance is described in the paper:
%  The Quadratic-Chi Histogram Distance Family 
%  Ofir Pele, Michael Werman
%  ECCV 2010
clc; close all; clear all;

D= 101; % Dimension of the feature histograms.
N= 42;  % Number of feature histograms in first object.
M= 7;   % Number of feature histograms in second object.
% The normalization factor. Should be 0 <= m < 1. 
% 0.9 experimentally yielded good results. 0.5 is the generalization of
% chi^2 which also yields good results.
m= 0.9;
% Distance threshold that above it similarity is 0.
% Note that since features are in the open interval (0,1)
% the maximum distance is sqrt(D)
threshold= 0.1 * sqrt(D);


PF= rand(D, N);
QF= rand(D, M);
PW= rand(1, N);
QW= rand(1, M);

% Anonymous function in Matlab
F_sim= @(F1,F2)( 1-min([norm(F1-F2) threshold])/threshold );
tic
dist= QC_signatures(PF, QF, PW, QW, F_sim, m);
fprintf('Computing QC_signatures took %f seconds.\n',toc);
fprintf(['Note that QC_signatures is written directly in Matlab and calls \n' ...
         'Matlab function handles, both are slow. It is on my TODO list to \n' ...
         'implement it as a mex.\n']);

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