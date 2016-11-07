%   Author: Victor May
%   Contact: mayvic(at)gmail(dot)com
%   $Date: 2011-11-19 $
%   $Revision: $
%
% Copyright 2011, Victor May
% 
%                          All Rights Reserved
% 
% All commercial use of this software, whether direct or indirect, is
% strictly prohibited including, without limitation, incorporation into in
% a commercial product, use in a commercial service, or production of other
% artifacts for commercial purposes.     
%
% Permission to use, copy, modify, and distribute this software and its
% documentation for research purposes is hereby granted without fee,
% provided that the above copyright notice appears in all copies and that
% both that copyright notice and this permission notice appear in
% supporting documentation, and that the name of the author 
% not be used in advertising or publicity pertaining to
% distribution of the software without specific, written prior permission.        
%
% For commercial uses contact the author.
% 
% THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO
% THIS SOFTWARE, INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
% FITNESS FOR ANY PARTICULAR PURPOSE.  IN NO EVENT SHALL THE AUTHOR BE 
% LIABLE FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL
% DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR
% PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS
% ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF
% THIS SOFTWARE.

% This function creates a synthetic dataset for test the SR algorithm.
% It's inputs are a reference image, a blur sigma, and a number of low-res 
% images to be generated.
% The outputs are a set of randomly translated low-res images, their
% translation offsets, and the original image cropped to the frame that can
% be restored from the low-res image set (their common area).
function [ images offsets croppedOriginal ] = SynthDataset(im, numImages, blurSigma)    
    padRatio = 0.2;
    
    workingRowSub = round(0.5 * padRatio * size(im, 1)) : round((1 - 0.5 * padRatio) * size(im, 1));
    workingColSub = round(0.5 * padRatio * size(im, 2)) : round((1 - 0.5 * padRatio) * size(im, 2));
    
    croppedOriginal = im(workingRowSub, workingColSub);

    offsets(1, :) = [ 0 0 ];
    images{1} = im(workingRowSub, workingColSub);    
    
    for i = 2 : numImages
        offsets(i, :) = 2 * rand - 1;
        offsetRowSub = workingRowSub - offsets(i, 2);
        offsetColSub = workingColSub - offsets(i, 1);
        [ x y ] = meshgrid(1 : size(im, 2), 1 : size(im, 1));
        [ x2 y2 ] = meshgrid(offsetColSub, offsetRowSub);
        images{i} = interp2(x, y, im, x2, y2);               
    end
    
    blurKernel = fspecial('gaussian', 3, blurSigma);
    
    for i = 1 : numImages
        images{i} = conv2(images{i}, blurKernel, 'same');
        curIm = images{i};
        images{i} = curIm(2 : 2 : end - 1, 2 : 2 : end - 1);
    end
end

