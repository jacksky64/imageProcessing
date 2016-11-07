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

% This function displays a set of low-resolution images, provided in a cell
% array.
function ShowLRImages(images)
    numCols = ceil(sqrt(numel(images)));
    numRows = numCols;
    
    for i = 1 : numRows
        for j = 1 : numCols
            imageInd = (i - 1) * numCols + j;
            subplot(numCols, numRows, imageInd);
            imshow(images{imageInd});
            hold on;
            title(sprintf('Low-Res Image No.%d', imageInd));
        end
    end
end

