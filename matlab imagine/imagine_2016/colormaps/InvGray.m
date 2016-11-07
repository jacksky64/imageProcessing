function dColormap = InvGray(iNBins)
%LOGGRAY Example custom colormap for use with imagine
%  DCOLORMAP = LOGGRAY(INBINS) returns a double colormap array of size
%  (INBINS, 3). Use this template to implement you own custom colormaps.
%  Imagine will interpret all m-files in this folder as potential colormap-
%  generating functions an list them using the filename.

% -------------------------------------------------------------------------
% Process input
if ~nargin, iNBins = 256; end
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create look-up tables (pairs of x- and y-vectors) for the three colors
dColormap = gray(iNBins);
dColormap = 1 - dColormap;
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION LogGray
% =========================================================================