%PRTVER Get PRTools version
%
%This routine is intended for internal use in PRTools only

function prtversion = prtver

persistent PRTVERSION
if ~isempty (PRTVERSION)
	prtversion = PRTVERSION;
	return
end

verstring = version;
if strcmp(computer,'MAC2') | verstring(1) == '5';
%	name = fileparts(which('fisherc'))
%	[pp,name,ext] = fileparts(name(1:end-1))
	ver_struct.Name = 'Pattern Recognition Tools';
	ver_struct.Version = '4.0.0';
	ver_struct.Release = '';
	ver_struct.Date = '';
	prtversion = {ver_struct datestr(now)};
else
% 	[pp,name,ext] =fileparts(fileparts(which('fisherc')));
% 	vers = ver([name,ext]);
% 	if isempty(vers)
% 		vers = 0;
%  		error([newline 'This version of PRTools is not properly defined as a toolbox.' ...
%  		newline 'Please add it first, e.g. using the addpath command with the path from root!'])
% 	end
% 	prtversion = {ver([name,ext]) datestr(now)};
	prtversion = {ver('prtools') datestr(now)};
end
PRTVERSION = prtversion;
