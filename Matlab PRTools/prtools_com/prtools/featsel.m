%FEATSEL Selection of known features
%
%   W = FEATSEL(K,J)
%
% INPUT
%   K    Input dimensionality
%   J    Index vector of features to be selected
%
% OUTPUT
%   W    Mapping performing the feature selection
%
% DESCRIPTION
% This is a simple support routine that writes feature selection
% in terms of a mapping. If A is a K-dimensional dataset and J are
% the feature indices to be selected, then B = A*W does the same as
% B = A(:,J).
%
% The use of this routine is a mapping V computed for a lower dimensional
% subspace defined by J can now be defined by W = FEATSEL(K,J)*V as a 
% mapping in the original K-dimensional space.
%
% The selected features can be retrieved by W.DATA or by +W.
% See below for various methods to perform feature selection.
%
% SEE ALSO
% MAPPINGS, DATASETS, FEATEVAL, FEATSELF, FEATSELLR,
% FEATSELO, FEATSELB, FEATSELI, FEATSELP, FEATSELM

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function w = featsel(k,j)

if isa(k,'dataset') 
%if isa(k,'dataset') & ismapping(j)
	nodatafile(k);
	w = k(:,j);
elseif isa(k,'mapping')
	w = k(:,j);
else
	if (any(j) > k | any(j) < 1)
		error('Features to be selected are not in proper range')
	end
	% w = mapping(mfilename,'trained',j(:)',[],k,length(j));
	% There seems to be no need to make this mapping 'trained'.
	% A fixed mapping could be used more easily.
	% For historical consistency it is left like this (RD)
	% On second sight a fixed mapping is needed for handling datafiles
	% w = mapping(mfilename,'trained',j(:)',[],k,length(j));
	w = mapping(mfilename,'fixed',j(:)',[],k,length(j));
	% w = mapping(mfilename,'combiner',j(:)',[],k,length(j));
	w = setname(w,'Feature Selection');
end
