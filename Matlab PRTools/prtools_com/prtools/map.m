%MAP Map a dataset, train a mapping or classifier, or combine mappings
%
%	B = MAP(A,W) or B = A*W
%
% Maps a dataset A by a fixed or trained mapping (or classifier) W,
% generating
% a new dataset B. This is done object by object. So B has as many objects
% (rows) as A. The number of features of B is determined by W. All dataset
% fields of A are copied to B, except the feature labels. These are defined
% by the labels stored in W.
%
%	V = MAP(A,W) or B = A*W
%
% If W is an untrained mapping (or classifier), it is trained by the dataset A.
% The resulting trained mapping (or classifier) is stored in V.
%
%	V = MAP(W1,W2) or V = W1*W2
%
% The two mappings W1 and W2 are combined sequentially. See SEQUENTIAL for
% a description. The resulting combination is stored in V.
%
% See also DATASETS, MAPPINGS, SEQUENTIAL

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% $Id: map.m,v 1.19 2010/06/10 22:31:12 duin Exp $

function [d, varargout] = map(a,b,batch)
		prtrace(mfilename);
    
% if map is already computed, take it
% if map needs to be stored, do so.
if nargout == 1 & nargin == 2 & stamp_map > 0
	d = stamp_map(a,b);
		if ~isempty(d)
			return
		end
end
	
if nargin < 3, batch = []; end
varargout = repmat({[]},[1, max((nargout-1),0)]);

global CHECK_SIZES  % enables the possibility to avoid checking of sizes
[ma,ka] = size(a);
[mb,kb] = size(b);

% force batch processing for large datasets
if isempty(batch) & ma >= 10000
	batch = 1000;
end

if ~isempty(batch) & ismapping(b) & isdataset(a) & ~isfeatim(a) & getbatch(b)
	% batch mode
	s = sprintf('Mapping %i objects: ',ma);
	prwaitbar(ma,s);
	%DXD map the first batch to setup the output dataset:
	dd = map(a(1:batch,:),b);
	%DXD first test if we are dealing with a mapping that outputs just a
	%single value (like testc):
	nb = size(dd,1);
	average_output = 0;
	if (nb~=batch)
		if (nb==1)
			warning('prtools:map:AverageBatchOutputs',...
			['The mapping appears to return a single object from a input',...
			newline,...
			'dataset. The objects resulting from different batches in the batch',...
			newline,'processing will be *averaged*.']);
			average_output = 1;
		end
	end
	kb = size(dd,2);
	nobatch = 0;
	if isdataset(dd)
		d = setdata(a,zeros(ma,kb));
% 		d = dataset(zeros(ma,kb),getlabels(a));
% 		d = setlablist(dd,getlablist(dd));
% 		if ~isempty(a,'prior')
% 			d = setprior(d,getprior(a,0));
% 		end
 		d = setfeatlab(d,getfeatlab(dd));
	elseif isa(dd,'double')
		d = zeros(ma,kb);
	else 
		% irregular, escape from batch processing
		nobatch = 1;
		prwaitbar(0);
	end
	d(1:batch,:) = dd;
	if ~nobatch
		n = floor(ma/batch);
		prwaitbar(ma,batch,[s int2str(batch)]);
		for j=2:n
			L = (j-1)*batch+1:j*batch;
			aa = doublem(a(L,:));
			d(L,:) = map(aa,b);
			prwaitbar(ma,j*batch,[s int2str(j*batch)]);
		end
		L = n*batch+1:ma;
		if ~isempty(L)
			aa = doublem(a(L,:));
			dd = map(aa,b);
			d(L,:) = dd;
		end
		if isdataset(d)
			featlabd = getfeatlab(d);
			d = setdat(a,d);
			d = setfeatlab(d,featlabd);
		end
		if average_output
			d = mean(d,1);
		end
		prwaitbar(0);
		return
	end
end

if iscell(a) | iscell(b)
% 	if (iscell(a) & min([ma,ka]) ~= 1) | (iscell(b)& min([mb,kb]) ~= 1)
% 		error('Only one-dimensional cell arrays are supported')
% 	end

	if iscell(a) & ~iscell(b)
		d = cell(size(a));
		[n,s,count] = prwaitbarinit('Mapping %i cells: ',numel(a));
		for i = 1:size(a,1);
		for j = 1:size(a,2);
			d{i,j} = map(a{i,j},b);
			count = prwaitbarnext(n,s,count);
		end
		end
	elseif ~iscell(a) & iscell(b)
		d = cell(size(b));
		[n,s,count] = prwaitbarinit('Mapping %i cells: ',numel(b));
		for i = 1:size(b,1);
		for j = 1:size(b,2);
			d{i,j} = map(a,b{i,j});
			count = prwaitbarnext(n,s,count);
		end
		end
	else
		if size(a,2) == 1 & size(b,1) == 1
			d = cell(length(a),length(b));
			[n,s,count] = prwaitbarinit('Mapping %i cells: ',numel(d));
			for i = 1:length(a)
			for j = 1:length(b)
				d{i,j} = map(a{i},b{j});
				count = prwaitbarnext(n,s,count);
			end
			end
		elseif all(size(a) == size(b))
			d = cell(size(a));
			[n,s,count] = prwaitbarinit('Mapping %i cells: ',numel(d));
			for i = 1:size(a,1)
			for j = 1:size(a,2)
				d{i,j} = map(a{i,j},b{i,j});
				count = prwaitbarnext(n,s,count);
			end
			end
		else
			error('Cell sizes do not match')
		end
			
	end
	return
end

if all([ma,mb,ka,kb] ~= 0) & ~isempty(a) & ~isempty(b) & ka ~= mb & CHECK_SIZES
	error(['Output size of first argument should match input size of second.' ...
		newline 'Checking sizes might be skipped by defining gloabal CHECK_SIZES = 0'])
end

if isa(a,'mapping') & isa(b,'mapping')
	
  if isempty(b) % empty mappings are treated as unity mappings
    d = a;
  elseif istrained(a) & isaffine(a) & istrained(b) & isaffine(b)
						% combine affine mappings
		d = affine(a,b);
  else
    d = sequential(a,b);
	end
	
elseif isa(a,'dataset') | isa(a,'datafile') | isa(a,'double') | isa(a,'uint8') | isa(a,'uint16') | isa(a,'dipimage')
  
	if isa(a,'uint8') | isa(a,'uint16') | isa(a,'dipimage')
		a = double(a);
	end
	
	if ~isa(b,'mapping')
		error('Second argument should be mapping or classifier')
	end

  if isempty(b) % treat empty mappings as unity mappings
    d = a;
    return
		% produce empty mapping (i.e. unity mapping)
		% if input data is empty
  elseif isempty(a)
		d = mapping([]);
    return
	  % handle scalar * mapping by .* (see times.m)
  elseif isa(a,'double') & ka == 1 & ma == 1
		d = a.*b;
		return; 
	end


	mapp = getmapping_file(b);

	if isuntrained(b)
		pars = +b;
		if issequential(b) | isstacked(b) | isparallel(b)
			%iscombiner(feval(mapp)) % sequentiall, parallel and stacked need
                               % special treatment as untrained combiners
      
      % matlab 5 cannot handle the case [d, varargout{:}] = feval when varargout is empty
      % because of this we have next piece of code
			if isempty(varargout) 
        d = feval(mapp,a,b);   
      else    
        [d, varargout{:}] = feval(mapp,a,b); 
      end 
		else
			if ~iscell(pars), pars = {pars}; end
			if isempty(varargout)
        d = feval(mapp,a,pars{:});
      else    
        [d, varargout{:}] = feval(mapp,a,pars{:});
      end 
		end
		if ~isa(d,'mapping')
			error('Training an untrained classifier should produce a mapping')
		end
		if getout_conv(b) > 1
			d = d*classc;
		end
		d = setscale(d,getscale(b)*getscale(d));
		name = getname(b);
		if ~isempty(name)
			d = setname(d,name);
		end
		d = setbatch(d,getbatch(b));

	elseif isdatafile(a) & istrained(b)
 		if issequential(b)
 			d = feval(mapp,a,b);
 		else
			d = addpostproc(a,{b}); % just add mapping to postprocesing and execute later
		end
		
	elseif isdatafile(a)
		try  % try whether this is a mapping that knows how to handle a datafile
			pars = getdata(b); % parameters supplied in fixed mapping definition
			if nargout > 0
				if isempty(varargout)
					d = feval(mapp,a,pars{:});
				else    
					[d, varargout{:}] = feval(mapp,a,pars{:});
     		end 
			else
				feval(mapp,a,pars{:})
				return
			end
		catch
			[lastmsg,lastid] = lasterr;
			if ~strcmp(lastid,'prtools:nodatafile')
				error(lastmsg);
			end
      d = addpostproc(a,{b}); % just add mapping to postprocesing and execute later
      return
		end
  elseif isfixed(b) & isparallel(b)
    d = parallel(a,b);
	elseif isfixed(b) | iscombiner(b)
		if ~isdataset(a) 
			a = dataset(a);
		end
		pars = getdata(b); % parameters supplied in fixed mapping definition
    if ~iscell(pars), pars = {pars}; end
		if nargout > 0
			if isempty(varargout)
				fsize = getsize_in(b);
				if any(fsize~=0) & ~isobjim(a)
					a = setfeatsize(a,fsize); % needed to set object images, sometimes
				end 
				d = feval(mapp,a,pars{:});  % sequential mappings are split! Solve there!
      else    
        [d, varargout{:}] = feval(mapp,a,pars{:});
      end 
		else
			feval(mapp,a,pars{:})
			return
		end

	elseif istrained(b)
		if ~isdataset(a) 
			a = dataset(a);
		end
		if isempty(varargout)
			fsize = getsize_in(b);
			if any(fsize~=0) & ~isobjim(a)
				a = setfeatsize(a,fsize); % needed to set object images, sometimes
			end
			d = feval(mapp,a,b);
    else    
      [d, varargout{:}] = feval(mapp,a,b);
    end 
		if ~isreal(+d)
			prwarning(2,'Complex values appeared in dataset');
		end
		if isdataset(d)
			d = setcost(d,b.cost);
			% see if we have reasonable data in the dataset
	
		end

	else
		error(['Unknown mapping type: ' getmapping_type(b)])
	end
	
  if isdataset(d) 
	
			% we assume that just a basic dataset is returned, 
			% including setting of feature labels, but that scaling
			% and outputconversion still have to be done.

			% scaling
		v = getscale(b);
		if length(v) > 1, v = repmat(v(:)',ma,1); end
		d = v.*d;
			% outputconversion
		switch 	getout_conv(b);
		case 1  % SIGM output
			if size(d,2) == 1
				d = [d -d]; % obviously still single output discriminant
				d = setfeatlab(d,d.featlab(1:2,:));
			end             
			d = sigm(d);
		case 2  % NORMM output
			if size(d,2) == 1
				d = [d 1-d]; % obviously still single output discriminant
				d = setfeatlab(d,d.featlab(1:2,:));
			end             % needs conversion to two-classes before normm
			d = normm(d);
		case 3  % SIGM and NORMM output
			if size(d,2) == 1
				d = [d -d]; % obviously still single output discriminant
				d = setfeatlab(d,d.featlab(1:2,:));
			end             % needs conversion to two-classes before sigmoid
			d = sigm(d);
			d = normm(d);
		end
		%DXD finally, apply the cost matrix when it is defined in the
		%mapping/dataset:
		d = costm(d);
	end

elseif isa(a,'mapping')
	if isa(b,'dataset')
		error('Datasets should be given as first argument')
	elseif isdouble(b) & isscalar(b)
		d = setscale(a,b*getscale(a));
	elseif istrained(a) & isdouble(b)
		d = a*affine(b);
	else
		error('Mapping not supported')
	end
		
else
	%a
	b
	error('Data type not supported')
end
