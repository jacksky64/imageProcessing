function [level, imgBw] = isodata(img, logArg)
% isodata    Compute global image threshold using iterative isodata method.
%
% inputs:
% img can be of any class.
% logArg, if supplied and equal to 'log', will apply a log transform to the image prior to thresholding.
% the log transform may result in a better threshold, if the variance of the foreground
% is considerably higher than the variance of the background.
% if your image has negative values, a log transform is not a good idea.
%
% outputs:
% level is the calculated threshold.
% even if logArg equals 'log', level is in units of the original image.
% regardless of the class of img, level is a double.
% imgBw is the thresholded (binary) image.
%
% JJH, 2013-11-09
%
% Reference: T.W. Ridler, S. Calvard, Picture thresholding using an iterative selection method, 
%            IEEE Trans. System, Man and Cybernetics, SMC-8 (1978) 630-632.

if nargin>1 && strcmp(logArg, 'log')
	img = log(double(img));
	1;end

maxIter = 1e2;
tol = 1e-6;
imgFlat = img(:);
ii = 1;
thresh(ii) = mean(imgFlat);
while ii<maxIter
	imgBw = img>thresh(ii);
	mbt = mean(imgFlat(~imgBw));
	mat = mean(imgFlat(imgBw));
	thresh(ii+1) = 0.5*(mbt + mat);
	if thresh(ii+1) - thresh(ii) > tol
		ii = ii + 1;
	else
		break
		1;end;1;end
level = thresh(end);

if nargin>1 && strcmp(logArg, 'log')
	level = exp(level);
	1;end
