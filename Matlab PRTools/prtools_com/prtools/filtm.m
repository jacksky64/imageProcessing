%FILTM Mapping to filter objects in datasets and datafiles
%
%		B = FILTM(A,FILTER_COMMAND,{PAR1,PAR2,....},SIZE)
%		B = A*FILTM([],FILTER_COMMAND,{PAR1,PAR2,....},SIZE)
%
% INPUT
%		A							  Dataset or datafile
%		FILTER_COMMAND	String with function name
%		{PAR1, ...	}	  Cell array with optional parameters to FILTER_COMMAND
%		SIZE						Output size of the mapping (default: input size)
%
% OUTPUT
%		B							  Dataset or datafile of images processed by FILTER_COMMAND
%
% DESCRIPTION
% For each object stored in A a filter operation is performed as
%
%		OBJECT_OUT = FILTER_COMMAND(OBJECT_IN,PAR1,PAR2,....)
%
% The results are collected and stored in B. In case A (and thereby B) is
% a datafile, execution is postponed until conversion into a dataset, or a
% call to SAVEDATAFILE or CREATEDATAFILE.
%
% EXAMPLES
% b = filtm(a,'conv2',{[-1 0 1; -1 0 1; -1 0 1],'same'});
% Performs a convolution with a horizontal gradient filter (see CONV2).
%
% There is a similar command FILTIM that is recommended for handling
% multi-band images.
%
% SEE ALSO
% DATASETS, DATAFILES, IM2OBJ, DATA2IM, IM2FEAT, DATGAUSS, DATFILT, FILTIM
% SAVEDATAFILE ,CREATEDATAFILE

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function b = filtm(a,command,pars,outsize)

	prtrace(mfilename);

	if nargin < 4, outsize = []; end
	if nargin < 3, pars = {}; end
	if nargin < 2
		error('No command given')
	end
	if ~iscell(pars), pars = {pars}; end
	
	mapname = 'dataset/file image filtering';
	
	if isempty(a)			% no data, so just mapping definition
		b = mapping(mfilename,'fixed',{command,pars});
		if ~isempty(outsize)
			b = setsize_out(b,outsize);
		end
		b = setname(b,mapname);
		
	elseif isdatafile(a)	             % for datafiles filters are stored
				
		if isempty(getpostproc(a)) & ~ismapping(command)
			                           % as preprocessing (if no postproc defined)
			b = addpreproc(a,command,pars,outsize);
		else		                     % or as mapping as postprocessing
			if ismapping(command)      % we have already a mapping
				v = command;
			else                       % just a string, construct mapping
				v = mapping(mfilename,'fixed',{command,pars});
				v = setname(v,mapname);
			end
			if ~isempty(outsize)       % user wants to set an output size (hope he has good reasons)
				v = setsize_out(v,outsize); % add it to mapping
			end
			b = addpostproc(a,v);      % store mapping
		end
		if ~isempty(outsize)
			b = setfeatsize(b,outsize); % set featsize equal to output size
		end
		return
		
	elseif isdataset(a) % are executed here
	 
		m = size(a,1);								 
		d = +a;
		imsize = getfeatsize(a);
		
		% Perform command on first image to check whether image size stays equal
		if length(imsize) == 1
			imsize = [1 imsize];
		end
		first = execute(command,reshape(d(1,:),imsize),pars);
		first = double(first); % for DipLib users
		if isempty(outsize)
			outsize = size(first);
		end
		% process all other images
		
		out = repmat(first(:)',m,1);
		for i = 2:m
			ima = double(execute(command,reshape(d(i,:),imsize),pars));
			sima = size(ima);
			if (any(outsize ~= sima(1:length(outsize))))
				error('All image sizes should be the same')
			end
			out(i,:) = ima(:)';
		end
		
		% store processed images in dataset
		
		b = setdata(a,out);
		b = setfeatsize(b,outsize);
		
	elseif iscell(a)
		
		b = cell(size(a));
		n = numel(b);
		s = sprintf('Filtering %i objects: ',n);
		prwaitbar(n,s);
		for i=1:n
			prwaitbar(n,i,[s int2str(i)]);
			b{i} = feval(mfilename,a{i},command,pars,outsize);
		end
		prwaitbar(0);
		
	else
		
		b = feval(command,a,pars{:});
		
	end
	
return

function out = execute(command,a,pars)

	exist_command = exist(command);
	if isstr(command) & any([2 3 5 6] == exist_command)
		
		out = feval(command,a,pars{:});
	elseif ismapping(command)
		out = map(a,command);
	else
		error('Filter command not found')
	end
 
return