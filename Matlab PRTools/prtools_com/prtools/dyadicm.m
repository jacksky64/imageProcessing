%DYADICM Dyadic dataset mapping
%
%   B = DYADICM(A,P,Q,SIZE)
%
% INPUT
%  A       Input dataset
%  P       Scalar multiplication factor (default 1)
%          or string (name of a routine)
%  Q       Scalar multiplication factor (default 1)
%          or feature size needed for splitting A
%  SIZE    Desired images size of output objects
%
% OUTPUT
%  B       Dataset
%
% DESCRIPTION
% This fixed mapping is a low-level routine to facilitate dyadic datafile
% operations. A should be a horizontal concatenation of two identically
% shaped datasets: A = [A1 A2]. B is now computed as B = P*A1 + Q*A2.
% The feature size for the objects in B is set to SIZE.
%
% If P is a string (name of a routine) the dataset A is horizontally
% split and COMMAND(A1,A2) is called, in which COMMAND is the name of the
% routine stored in P.
% 
% If P is a string and Q is a number then the above split is made using
% the first Q columns (features) of A for A1 and the remaining for A2.
%
% This routine has been written for use by PRTools programmers only.
% Note that although this routine shows itself as a fixed mapping, it
% is sometimes externally set to a combiner.
%
% SEE ALSO
% DATASETS, MAPPINGS, DATAFILES

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands


function b = dyadicm(a,p,q,fsize)

	prtrace(mfilename,2); 
	
	if nargin < 4, fsize = []; end
	if nargin < 3, q = []; end
	if nargin < 2, p = []; end
	if nargin < 1 | isempty(a)
		% note that this routine is sometimes externally set to a combiner
		b = mapping(mfilename,'fixed',{p,q,fsize});
		b = setsize_out(b,prod(fsize));
		b = setname(b,'dyadicm');
		return
	end
	
	if isempty(p), p = 1; end
	
	if ismapping(a)
		% note that this routine is sometimes externally set to a combiner
		if istrained(a)
			b = a*mapping(mfilename,'fixed',{p,q,fsize});
		else
			b = mapping(mfilename,'untrained',{a,p,q,fsize});
		end
	
	elseif isdataset(a) & ismapping(p)
		pdata = getdata(p);
		c = getsize(a,3);  % number of classes, size of mappings
		w = a*pdata{1};    % training the stacked untrained classifier
		v = feval(mfilename,[],pdata{2:3},c); % prepare dyadicm
		v = setsize_in(v,2*c); % and its input size
		b = w*v;               % feed it with the stacked classifiers
		b = setlabels(b,getlablist(a)); % set its output labels.
			
	else % the basic call by data and parameters
		
		% The dataset A has horizontally to be split in two datasets A1, A2. 
		% If P and Q are scalars or if Q = [], this is done half-half.
		% If P is a string (name of a routine) and Q is a number, this is
		% interpreted as the number of columns (features) of A that go to A1.
		% The remaining part goes to A2.
		[a1,a2,fsize] = split_dataset(a,p,q,fsize);

		if isstr(p) % some routine tells us what to do
			if isempty(q)
				b = feval(p,a1,a2);	
			else
				b = feval(p,a1,a2,q{:});
			end
		else % addition
			if isempty(q), q = 1; end
			b = p*a1 + q*a2;
		end
		
		if ~isdataset(b)
			b = double(b); % convert in case of logicals or DipImage
		elseif ~isempty(fsize) & ~iscell(a)  % can a be a cell?
			b = setfeatsize(b,fsize);
		end
		
	end
	
return

function [a1,a2,fsize] = split_dataset(a,p,q,fsize)

	if iscell(a)
    
    a1 = double(a{1});
    a2 = double(a{2});
    
	elseif isstr(p) & ~isempty(q)
		
		isdataset(a);
		fsize = q;
		a1 = a(:,1:q);
		a2 = a(:,q+1:end);
		
	else
		
	  isdataset(a);
	  k = size(a,2);
	  if isempty(fsize) | fsize == 0
		  fsize = k/2;
	  end
	
	  if 2*prod(fsize) ~= k
		  error('Desired feature size should be half of input feature size')
	  end
	
	  if k ~= 2*floor(k/2)
		  error('Feature size of dataset should be multiple of 2')
	  end
		
    a1 = a(:,1:k/2);
    a2 = a(:,k/2+1:k);
  	
  end
