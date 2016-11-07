%WEAKC Weak Classifier
%
%   [W,V] = WEAKC(A,ALF,ITER,R)
%   VC = WEAKC(A,ALF,ITER,R,1)
%
% INPUT
%   A    Dataset
%   ALF  Fraction of objects to be used for training (def: 0.5)
%   ITER Number of trials
%   R    R = 0: use NMC (default)
%        R = 1: use FISHERC
%        R = 2: use UDC
%        R = 3: use QDC
%        otherwise arbitrary untrained classifier
%
% OUTPUT
%   W    Best classifier over ITER runs
%   V    Cell array of all classifiers
%        Use VC = stacked(V) for combining
%   VC   Combined set of classifiers
%
% WEAKC uses subsampled versions of A for training. Testing is done
% on the entire training set A. The best classifier is returned in W.
%
%  SEE ALSO
%  MAPPINGS, DATASETS, FISHERC, UDC, QDC

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function [w,v] = weakc(a,n,iter,r,s)

	prtrace(mfilename);

%               INITIALISATION

if nargin < 5, s = 0; end
if nargin < 4, r = 0; end
if nargin <3, iter = 1; end
if nargin < 2, n = 1; end
if nargin < 1 | isempty(a)
    w = mapping(mfilename,{n,iter,r,s});
    w = setname(w,'Weak');
    return
end

%                 TRAINING

v = {};
emin = 1;

for it = 1:iter              % Loop
	b = gendat(a,n);           % subsample training set
	if ~ismapping(r)           % select classifier and train
		if r == 0
    	ww = nmc(b); 
		elseif r == 1
    	ww = fisherc(b); 
		elseif r == 2
			ww = udc(b);
		elseif r == 3
			ww = qdc(b);
		else
			error('Illegal classifier requested')
		end
	else
		ww = b*r;
	end
	v = {v{:} ww};              % store all classifiers in v
	                            % select best classifier and store in w
	e = a*ww*testc;
	if e < emin
		emin = e;
		w = ww;
	end
end

if s == 1
	w = stacked(v);
end

return