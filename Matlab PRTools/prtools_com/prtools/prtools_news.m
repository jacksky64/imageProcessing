%PRTOOLS_NEWS  List PRTools news and download new versions
%
%    PRTOOLS_NEWS                      List PRTools news
%    PRTOOLS_NEWS(DIRNAME,UNZIP)       Reload PRTools
%
% DIRNAME is the directory to download PRTools. If UNZIP == 1
% (default 0) it is unzipped. 

function out = prtools_news(dirname,unzip_link)

% to be implemented later:
% try
% 	% fake, just to be sure that PRTools datasets are used
% 	dataset(rand(5,2),genlab(5),'name','apple');
% catch
% 	error([newline 'PRTools has not been properly installed. It should be at the top of' ...
% 		newline 'the Matlab path. After restarting Matlab adjust and save the path' ...
% 		newline 'and give ''prtools'' as the first command']);
% end
% 
% if nargin > 0 & ~isempty(dirname)
% 	if dirname == -1
% 		return % this was just a test to see whether PRTools was properly installed
% 	end
% end
	
if ~usejava('jvm')
	if nargout == 1
		out = '    No Java (JVM) installed, some commands cannot be used';
	elseif nargin == 0
		error('Java (JVM) has not been installed, so the ''prtools''-command does not work')
	end
end

if nargin < 2, unzip_link = 0; end

[links,mod] = readlinks;

if nargin == 0
	if nargout == 0
		if isempty(links)
			error('Error in reaching PRTools web links');
		else
			web(links{1},'-browser');
		end
	else
		out = mod; % needed for call in dataset
	end
elseif nargin == 1 & dirname == 0  % read mod
	disp(mod);
elseif isempty(links)
	error('Error in reaching PRTools web links');
else
	if isempty(dirname)
		dirname = pwd;
	end
	if ~isstr(dirname)
		n = dirname;
		dirname = pwd;
	else
		n = 2;
	end
	[pp,ff] = fileparts(links{n});
	if unzip_link
		[pp,ff] = fileparts(links{n});
		fprintf(1,'Downloading and unzipping %s ....\n',ff)
		unzip(links{n},dirname);
		disp('Download ready');
	else
		if exist(dirname) == 0
			mkdir(dirname);
		end
		fprintf(1,'Downloading %s ....\n',ff)
		[pathname,filename,ext] = fileparts(links{n});
		fname = fullfile(dirname,[filename ext]);
		if ~usejava('jvm') & isunix
			[status,fname] = unix('wget -q -O - http://prtools.org/files/prtoolslinks.txt');
			if status > 1
				error('Download failed, no Java?')
			end
		else
			[pathname,status] = urlwrite(links{n},fname);
		end
		disp('Download ready');
	end
end







		
		