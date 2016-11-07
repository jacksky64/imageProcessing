%SEQUENTIAL Sequential mapping
%
%   V = SEQUENTIAL(W1,W2) 
%   B = SEQUENTIAL(A,W)
%
% INPUT
%   W,W1,W2  Mappings
%   A        Dataset
%
% OUTPUT
%   V        Sequentially combined mapping
%   B        Dataset
%
% DESCRIPTION
% The two mappings W1 and W2 are combined into a single mapping V. Note 
% that SEQUENTIAL(W1,W2) is equivalent to W1*W2. If W2 is a mapping of 
% a type 'combiner', it is called to make a combination attempt.
%	SEQUENTIAL(A,W) maps the dataset A by the sequential mapping W.
%
% This routine is automatically called to execute W = W1*W2 or B = A*W2 in
% case W2 is a sequential mapping. It should not be directly called by users.
%
% SEE ALSO
% MAPPINGS, DATASETS

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: sequential.m,v 1.6 2010/06/25 09:52:40 duin Exp $

function w = sequential(w1,w2,w3)
	
	prtrace(mfilename);
	
	% Just necessary to inform MAP.
	if (nargin == 0) 
		w = mapping(mfilename,'combiner');
		return;
	end
	[m1,k1] = size(w1); 
	[m2,k2] = size(w2);
	if (~isa(w2,'mapping'))
		error('Second argument should be a mapping.')
	end

	if isa(w1,'mapping') 
		% Definition
    if isempty(w1) % treat empty mapping as unity mapping
      w = w2;
    elseif (iscombiner(w2))
			% Execute the mapping W2.
			map = getmapping_file(w2);
			pars = getdata(w2);
			w = feval(map,w1,pars{:});
		else 
			% W2 is just a general mapping.
			if (k1 > 0) & (m2 > 0) & (k1 ~= m2)
				error('Inner mapping/data sizes do not agree.')
			end

			% Define the mapping type after combining W1 and W2.
			if (isuntrained(w1)) | (isuntrained(w2))
				mappingtype = 'untrained';
			elseif (istrained(w1)) | (istrained(w2))
				mappingtype = 'trained';
			else
				mappingtype = 'fixed';
			end
			
			if strcmp(mappingtype,'untrained')
				labels = [];
				size_in = 0;
				size_out = 0;
			elseif (m2 == 0 | k2 == 0) & (m1 ~= 0) & (k1 ~= 0) 
				% E.G. TRAINED * FIXED
				labels   = getlabels(w1);
				size_in  = getsize_in(w1);
				size_out = getsize_out(w1);

			elseif (m2 ~= 0) & (k2 ~= 0) & (m1 == 0 | k1 == 0) 
				% FIXED * TRAINED
				labels   = getlabels(w2);
				size_in  = getsize_in(w2);
				size_out = getsize_out(w2);

			elseif ~istrained(w2)         
				% TRAINED * FIXED
				labels   = getlabels(w1);
				size_in  = getsize_in(w1);
				size_out = getsize_out(w2);

			else                    	
				% TRAINED * TRAINED
				labels = getlabels(w2);
				size_in = getsize_in(w1);
				size_out = getsize_out(w2);
			end
			w = mapping(mfilename,mappingtype,{w1,w2},labels,size_in,size_out);
		end
		w = setbatch(w,(getbatch(w1) & getbatch(w2)));

  elseif isempty(w2) % treat empty mapping as unity mapping
    w = w1;

  else
		% Execution. We are here, when SEQUENTIAL(A,V) is called.
		if nargin == 3 % needed as MAP breaks down sequential mappings
			w2 = w2*w3;  % restore them!
		end
		a = w1;
		if (~isa(a,'double')) & (~isa(a,'dataset'))
			error('Just datasets or doubles can be mapped.')
		end
		% V can be a more complex mapping.
		v = +w2; v1 = v{1}; v2 = v{2};
		if (isuntrained(v1))
			if (isuntrained(v2))
				u = a*v1;
				w = u*(a*u*v2);
			else
				w = a*v1*v2;
			end
		else
			if (isuntrained(v2))
				w = v1*(a*v1*v2);
				% may be v1 changed the dimensionality, reset it: 
				w = setsize_in(w,size(a,2));
			else
				w = a*v1*v2;
				featlabels = getlabels(w2);
				if (isdataset(w)) & ~isempty(featlabels)
					w = setfeatlab(w,featlabels);
				end
			end
		end
		if ismapping(w)
			w = setbatch(w,getbatch(w2));
		end
	end
return;
