%TESTDATASIZE of datafiles and convert to dataset
%
%	 B = TESTDATASIZE(A,STRING,FLAG)
%
% INPUT
%  A         DATAFILE or DATASET
%  STRING    'data' (default) or 'features' or 'objects'
%  FLAG      TRUE / FALSE, (1/0)  (Default TRUE)
%
% OUTPUT
%  B         DATASET (if FLAG == 1 and conversion possible)
%            TRUE if FLAG == 0 and conversion possible
%            FALSE if FLAG == 0 and conversion not possible%
% DESCRIPTION
% If FLAG == 1, depending on the value of PRMEMORY and the size of the 
% datafile A, it is converted to a dataset, otherwise an error is generated.
% If FLAG == 0, depending on the value of PRMEMORY and the size of the
% datafile A, the output B is set to TRUE (conversion possible) or FALSE
% (conversion not possible).
%
% The parameter STRING controls the type of comparison:
%
% 'data'          PROD(SIZE(A)) < PRMEMORY
% 'objects'       SIZE(A,1).^2  < PRMEMORY
% 'features'      SIZE(A,2).^2  < PRMEMORY
%
% SEE ALSO
% DATASETS, DATAFILES, PRMEMORY

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = testdatasize(a,type,flag)

	prtrace(mfilename);

	if nargin < 3,
		flag = 1;
	end
	
	if nargin < 2
		type = 'data';
	end
	
	%if isdataset(a) & 0 % neglect: test of datasets not appropriate
	if isdataset(a) | isdouble(a)
		if flag
			b = a;
		else
			b = 1;
		end
		return
	end
	
  % Now we have a datafile
	a = setfeatsize(a,0); % featsize of datafiles is unreliable
	b = 1;
	switch type
		case 'data'
			if prod(size(a)) > prmemory
				if flag
					error(['Dataset too large for memory.' newline ...
          'Size is ' int2str(prod(size(a))) ', memory is ' int2str(prmemory) newline ...
			   	'Reduce the data or increase the memory by prmemory.'])
				else
					b = 0;
				end
			end
		case 'objects'
			if size(a,1).^2 > prmemory
				if flag
					error(['Number of objects too large for memory.' newline ...
          'Size is ' int2str(size(a,1).^2) ', memory is ' int2str(prmemory) newline ...
			   	'Reduce the data or increase the memory by prmemory.'])
				else
					b = 0;
				end
			end
		case 'features'
			if size(a,2).^2 > prmemory
				if flag
					error(['Number of features too large for memory.' newline ...
          'Size is ' int2str(size(a,2).^2) ', memory is ' int2str(prmemory) newline ...
			   	'Reduce the data or increase the memory by prmemory.'])
				else
					b = 0;
				end
			end
		otherwise
			error('Unknown test requested')
	end
	if nargout > 0
		if flag
			b = dataset(a);
		end
	end
	
return
