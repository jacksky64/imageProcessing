function dColormap = French(iNBins)
%OPTIMALCOLORS Example custom colormap for use with imagine
%  DCOLORMAP = OPTIMALCOLOR(INBINS) returns a double colormap array of size
%  (INBINS, 3). Use this template to implement you own custom colormaps.
%  Imagine will interpret all m-files in this folder as potential colormap-
%  generating functions an list them using the filename.

% -------------------------------------------------------------------------
% Process input
if ~nargin, iNBins = 256; end
iNBins = uint16(iNBins);
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Create look-up tables (pairs of x- and y-vectors) for the three colors
dYRed = [0; 1; 0.5];
dXRed = [1; 128; 256];

dYGrn = [0;  1;   0];
dXGrn = [1; 128; 256];

dYBlu = [0.5;  1;   0];
dXBlu = [1; 128; 256];
% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Interpolate and concatenate vectors to the final colormap
dRedInt = interp1(dXRed, dYRed, linspace(1, 255, iNBins)');
dGrnInt = interp1(dXGrn, dYGrn, linspace(1, 255, iNBins)');
dBluInt = interp1(dXBlu, dYBlu, linspace(1, 255, iNBins)');

dColormap = [dRedInt, dGrnInt, dBluInt];
% -------------------------------------------------------------------------

% =========================================================================
% *** END OF FUNCTION OptimalColor
% =========================================================================