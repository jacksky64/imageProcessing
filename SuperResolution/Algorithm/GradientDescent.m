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

% A simple implementation of a gradient descent optimization.
function x = GradientDescent(lhs, rhs, initialGuess)
   maxIter = 100;
   iter = 0;
   eps = 0.01;
   
   x = initialGuess;
   res = lhs' * (rhs - lhs * x);
   mse = res' * res;
   mse0 = mse;
   while (iter < maxIter && mse > eps^2 * mse0)
       res = lhs' * (rhs - lhs * x);
       x = x + res;
       mse = res' * res;
       fprintf(1, 'Gradient Descent Iteration %d mean-square error %3.3f\n', iter, mse);
       iter = iter + 1;
   end

end