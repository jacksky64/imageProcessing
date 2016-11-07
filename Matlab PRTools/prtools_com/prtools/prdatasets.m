%PRDATASETS Checks availability of a PRTOOLS dataset
%
%   PRDATASETS
%
% Checks the availability of the PRDATASETS directory, downloads the
% Contents file and m-files if necessary and adds it to the search path. 
% Lists Contents file.
%
%		PRDATASETS(DSET)
%
% Checks the availability of the particular dataset DSET. DSET should be
% the name of the m-file. If it does not exist in the 'prdatasets'
% directory an attempt is made to download it from the PRTools web site.
%
%		PRDATASETS(DSET,SIZE,URL)
%
% This command should be used inside a PRDATASETS m-file. It checks the 
% availability of the particular dataset file and downloads it if needed. 
% SIZE is the size of the dataset in Mbyte, just used to inform the user.
% In URL the web location may be supplied.  Default is 
% http://prtools.org/prdatafiles/DSET.mat
%
% All downloading is done interactively and should be approved by the user.
%
% SEE ALSO
% DATASETS, PRDATAFILES, PRDOWNLOAD

% Copyright: R.P.W. Duin, r.p.w.duin@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

function prdatasets(dset,siz,url)

if nargin < 3, url = []; end
if nargin > 0 & isempty(url)
	url = ['http://prtools.org/prdatasets/' dset '.mat']; 
end
if nargin < 2, siz = []; end
if nargin < 1, dset = []; end
dirname = fullfile(cd,'prdatasets');

if exist('prdatasets/Contents','file') ~= 2
	path = input(['The directory prdatasets is not found in the search path.' ... 
		newline 'If it exists, give the path, otherwise hit the return for an automatic download.' ...
		newline 'Path to prdatasets: '],'s');
	if ~isempty(path)
		addpath(path);
		feval(mfilename,dset,siz);
		return
	else
		dirname = fullfile(cd,'prdatasets');
		[ss,dirname] = prdownload('http://prtools.org/prdatasets/prdatasets.zip',dirname);
		addpath(dirname)
	end
end

if isempty(dset) % just list Contents file
	
	help('prdatasets/Contents')
	
elseif ~isempty(dset) & nargin == 1 % check / load m-file
	% this just loads the m-file in case it does not exist and updates the
	% Contents file
	if strcmp(dset,'renew')
		if exist('prdatasets/Contents','file') ~= 2
			% no prdatasets in the path, just start
			feval(mfilename);
		else
			dirname = fileparts(which('prdatasets/Contents'));
			prdownload('http://prtools.org/prdatasets/prdatasets.zip',dirname);
		end
	elseif exist(['prdatasets/' dset],'file') ~= 2
		prdownload(['http://prtools.org/prdatasets/' dset '.m'],dirname);
		prdownload('http://prtools.org/prdatasets/Contents.m',dirname);
	end
	
else   % now we load the m-file as well as the data given by the url
	
	% feval(mfilename,dset); % don't do this to allow for different mat-file
	% naming
	rootdir = fileparts(which('prdatasets/Contents'));
	[pp,ff,xx] = fileparts(url);
	if exist(fullfile(rootdir,[ff xx]),'file') ~= 2
		siz = ['(' num2str(siz) ' MB)'];
		q = input(['Dataset is not available, OK to download ' siz ' [y]/n ?'],'s');
		if ~isempty(q) & ~strcmp(q,'y')
			error('Dataset not found')
		end
		prdownload(url,rootdir);
		disp(['Dataset ' dset ' ready for use'])
	end
end
