%TYPP list M-File of PRTools
%    TYPE foo.bar lists the ascii file called 'foo.bar'.
%
%    TYPE foo lists the ascii file called 'foo.m'. 
% 
%    If files called foo and foo.m both exist, then
%       TYPE foo lists the file 'foo', and
%       TYPE foo.m list the file 'foo.m'.
% 
%    TYPE FILENAME lists the contents of the file given a full pathname
%    or a MATLABPATH relative partial pathname (see PARTIALPATH).
% 
%    See also DBTYPE, WHICH, HELP, PARTIALPATH.
%
%    This routine is overloaded by PRTools replacing tabs by two spaces

function typp(file)

[pp,prtools_dir,ext] =fileparts(fileparts(which('typp')));
[pp,file_dir,ext] =fileparts(fileparts(which(file)));
if strcmp(prtools_dir,file_dir) & exist(file)==2
	fid = fopen([deblank(file),'.m'],'r');
	if fid < 0
  		builtin('type',file);
	else
		s = fscanf(fid,'%c');
		r = [];
		w = [0,find(s==9)];
		for j = 1:length(w)-1
			r = [r,s(w(j)+1:w(j+1)-1),32,32];
		end
		r = [r,s(w(end)+1:end)];
		r = setstr(r);
		disp(r)
		fclose(fid);
	end
else
	builtin('type',file);
end
