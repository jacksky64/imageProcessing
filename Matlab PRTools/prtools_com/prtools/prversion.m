%PRVERSION PRtools version number
%
%		[VERSION,STR,DATE] = PRVERSION
%
% OUTPUT
%		VERSION   Version number (double)
%		STR				Version number (string)
%		DATE			Version date (string)
%
% DESCRIPTION
% Returns the numerical version number of PRTools VER (e.g. VER = 3.2050) 
% and as a string, e.g. STR = '3.2.5'. In DATE, the version date is returned 
% as a string. 

% $Id: prversion.m,v 1.2 2006/03/08 22:06:58 duin Exp $

function [version,str,date] = prversion

	signature = prtver;
	str = signature{1}.Version;
	date = signature{1}.Date;
	version   = str2num(str(1)) + (str2num(str(3))*1000 + str2num(str(5))*10)/10000;
	if nargout == 0
		disp([newline '   PRTools version ' str newline])
		clear version
	end

return;
