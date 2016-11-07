%DATASETM Mapping conversion to dataset
%
%   B = DATASETM(A)
%   B = A*DATASETM
%
% INPUT
%   A    Datafile or double array
%
% OUTPUT
%   B    DATASET
%
% DESCRIPTION
% This command is almost identical to B = DATASET(A), except that it
% supports the mapping type of construct: B = A*DATASETM. This may be
% especially useful to include the dataset conversion in the processing
% definitions of a datafile.
%
% SEE ALSO
% DATASETS, DATAFILES, MAPPINGS, DATASET

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = datasetm(a)

if nargin < 1
	b = mapping(mfilename,'fixed');
elseif isdataset(a)
	b = a;
elseif isdatafile(a) | isa(a,'double')
	b = dataset(a);
else
	error('Unexpected input')
end

	
