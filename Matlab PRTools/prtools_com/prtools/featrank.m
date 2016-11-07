%FEATRANK Feature ranking on individual performance for classification
% 
% 	[I,F] = FEATRANK(A,CRIT,T)
% 
% INPUT
%       A      input dataset
%       CRIT   string name of a method or untrained mapping
%       T      validation dataset (optional)
%
% OUTPUT
%       I      vector with sorted feature indices
%       F      vector with criteria values
%
% DESCRIPTION
% Feature ranking based on the training dataset A. CRIT determines  
% the criterion used by the feature evaluation routine feateval. If 
% the dataset T is given, it is  used as test set for feateval. In I 
% the features are returned in decreasing performance. In F the 
% corresponding values of feateval are given. Default: crit='NN'.
% 
% SEE ALSO
% MAPPINGS, DATASETS, FEATEVAL, FEATSELO, FEATSELB, FEATSELF,
% FEATSELP, FEATSELM

% Copyright: R.P.W. Duin, duin@ph.tn.tudelft.nl
% Faculty of Applied Sciences, Delft University of Technology
% P.O. Box 5046, 2600 GA Delft, The Netherlands

% $Id: featrank.m,v 1.3 2007/04/21 23:06:46 duin Exp $

function [I,F] = featrank(a,crit,t)

	prtrace(mfilename);
	
	[m,k,c] = getsize(a);
	F = zeros(1,k);
	if nargin < 3
		t = [];
	end
	if nargin < 2
		crit = 'NN';
		prwarning(4,'set criterion to NN');
	end

	isvaldfile(a,1,2); % at least 1 object per class, 2 classes
	a = testdatasize(a);
	iscomdset(a,t);
	
	if isempty(t)
		for j = 1:k
			F(j) = feateval(a(:,j),crit);
		end
	else
		% run the criterion on the validation set
		for j = 1:k
			F(j) = feateval(a(:,j),crit,t(:,j));
		end
	end
	
	[F,I] = sort(-F);
	F = -F;

return
