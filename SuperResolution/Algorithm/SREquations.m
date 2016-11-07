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

% Creates the Super-Resolution linear equations for the given data.
% The imaging model implemented here is spatial translation->blur->decimation.
% The boundary conditions are circular.
% The output arguments lhs and rhs are the left-hand side and right-hand
% sides of a linear system whose solution is the super-resolution image.
function [ lhs rhs ] = SREquations(images, offsets, blurSigma)
    lhs = [];
    rhs = [];
    superSize = 2 * size(images{1}) + [ 1 1 ];
    for i = 1 : numel(images)
        transMat = TransMat(superSize, offsets(i, :));
        blurMat = BlurMat(superSize, blurSigma);
        decMat = DecMat(superSize);
        
        curLhs = decMat * blurMat * transMat;
        curRhs = images{i};
        lhs = [ lhs ; curLhs ];
        rhs = [ rhs ; curRhs(:) ];
    end
end

% Creates a translation operator.
function transMat = TransMat(superSize, offsets)
    transposeMat = TransposeMat(superSize);
    transMat = ...
        transposeMat * TransMatY(superSize, offsets(1)) ...
      * transposeMat * TransMatY(superSize, offsets(2));
end

% Creates a translation operator for the image Y axis.
function transMatX = TransMatY(superSize, offset)
    row1 = zeros(1, prod(superSize));
    nzInd = floor(1 - offset) : ceil(1 - offset);
    filterValues = LinearKernel(1 - offset - nzInd);
    nzInd(nzInd < 1) = prod(superSize) - nzInd(nzInd < 1);
    row1(nzInd) = filterValues;
    col1 = zeros(1, prod(superSize));
    col1(1) = row1(1);
    col1(2) = row1(end);
    transMatX = sptoeplitz(col1, row1);    
end

% Creates a matrix transposition operator.
function transposeMat = TransposeMat(superSize)
    [ row col ] = meshgrid(1 : superSize(1), 1 : superSize(2));
    inputPixInd = sub2ind(superSize, row, col);
    outputPixInd = sub2ind(superSize, col, row);
    transposeMat = sparse(outputPixInd, inputPixInd, ones(size(outputPixInd)));
end

% Creates a blurring operator.
function blurMat = BlurMat(superSize, blurSigma)
    transposeMat = TransposeMat(superSize);
    blurMat = ...
        transposeMat * BlurMatY(superSize, blurSigma) ...
      * transposeMat * BlurMatY(superSize, blurSigma);
end

% Creates a blurring operator for the Y axis.
function blurMatY = BlurMatY(superSize, blurSigma)
    blurKernel = GaussianKernel(-1 : 1, blurSigma);
    blurKernel = blurKernel ./ sum(blurKernel(:));
    row1 = zeros(1, prod(superSize));
    row1([ end 1 2 ] ) = blurKernel;
    col1 = zeros(1, prod(superSize));
    col1(1) = row1(1);
    col1(2) = row1(2);
    blurMatY = sptoeplitz(col1, row1);
end

% Creates a decimation operator.
function decMat = DecMat(superSize)
    sampledSize = 0.5 * (superSize - 1);
    [ outputRow outputCol ] = meshgrid(1 : sampledSize(1), 1 : sampledSize(2));
    inputRow = 2 * outputRow;
    inputCol = 2 * outputCol;
    
     inputInd = sub2ind(superSize, inputRow, inputCol);
     outputInd = sub2ind(sampledSize, outputRow, outputCol);
     decMat = sparse(outputInd, inputInd, ones(numel(outputInd), 1), prod(sampledSize), prod(superSize));

end